import argparse
import logging
import queue as queue_module
import shutil
import sys
import time
import traceback
from multiprocessing import Event, Process, Queue
from pathlib import Path
from typing import List

from libefiling import generate_sha256, get_doc_id, parse_archive

from mona.compute_path import compute_path
from mona.config import TARGET_DOCUMENT_CODES, image_params
from mona.find_archives import find_archives, find_extracted_directories
from mona.logger import setup_child_logging, setup_logger
from mona.parse import parse


def get_args() -> dict:
    p = argparse.ArgumentParser(
        description='An application for parsing XML handled by the Internet Application Software.'
    )
    p.add_argument('src_dir', type=str, help='Directory containing archives')
    p.add_argument(
        'output_dir',
        type=str,
        help='Directory to store parsed output in production mode.',
    )
    p.add_argument(
        'doc_code',
        nargs='+',
        choices=TARGET_DOCUMENT_CODES,
        help='document codes to parse',
    )
    p.add_argument(
        '-l',
        '--log_level',
        type=str,
        choices=['info', 'debug'],
        default='info',
        help='Logging level',
    )
    p.add_argument(
        '-m',
        '--multi-processors',
        type=int,
        choices=[1, 2, 3, 4],
        default=1,
        help='Number of processors to use',
    )
    p.add_argument(
        '-o', '--overwrite', action='store_true', help='Overwrite existing output'
    )
    p.add_argument(
        '--mode',
        choices=['production', 'development'],
        default='production',
        help='Enable production mode',
    )
    args = p.parse_args()
    print(args)
    src_dir = Path(args.src_dir)
    output_dir_root = Path(args.output_dir)
    if not src_dir.exists():
        print(f'Source directory {args.src_dir} does not exist.')
        sys.exit(1)
    if not output_dir_root.exists():
        print(f'Output directory {args.output_dir} does not exist.')
        sys.exit(1)

    return {
        'src_dir': src_dir,
        'output_dir_root': output_dir_root,
        'doc_code': args.doc_code,
        'log_level': args.log_level,
        'num_processors': args.multi_processors,
        'overwrite': args.overwrite,
        'mode': args.mode,
    }


def multi_processes_parent(
    src_dir: Path,
    output_dir_root: Path,
    doc_code: List[str],
    log_level: str,
    overwrite: bool,
    num_processors: int,
    mode: str,
):

    queue = Queue()
    stop_event = Event()
    processes: List[Process] = []
    log_queue, listener = setup_logger(log_level=log_level)

    def _enqueue_sentinels() -> None:
        for _ in range(num_processors):
            queue.put(None)

    def _join_or_terminate(timeout_sec: float = 5.0) -> None:
        # Prevent the parent from hanging forever when a child does not exit.
        deadline = time.time() + timeout_sec
        for p in processes:
            remaining = max(0.0, deadline - time.time())
            p.join(timeout=remaining)
        for p in processes:
            if p.is_alive():
                p.terminate()
        for p in processes:
            p.join(timeout=1.0)

    for _ in range(num_processors):
        p = Process(
            target=multi_processes_child,
            args=(
                output_dir_root,
                queue,
                log_queue,
                log_level,
                overwrite,
                stop_event,
                mode,
            ),
        )
        p.start()
        processes.append(p)

    try:
        # give archive to each processes via queue
        iterator = (
            find_archives(str(src_dir), doc_code)
            if mode == 'production'
            else find_extracted_directories(str(src_dir), doc_code)
        )
        for item in iterator:
            if stop_event.is_set():
                break
            queue.put(item)

        # 正常終了ルート：sentinel投入
        _enqueue_sentinels()

    except KeyboardInterrupt:
        stop_event.set()
        # 子がqueue.getから抜けられるようにsentinelを投げる
        _enqueue_sentinels()
    except Exception:
        # 親側の想定外エラーでも子を停止させてから再送出する。
        stop_event.set()
        _enqueue_sentinels()
        raise
    finally:
        _join_or_terminate(timeout_sec=5.0)
        listener.stop()
        queue.close()
        queue.join_thread()


def multi_processes_child(
    output_dir_root,
    queue,
    log_queue,
    log_level,
    overwrite: bool,
    stop_event,
    mode: str,
):
    setup_child_logging(log_queue, log_level)
    while True:
        if stop_event.is_set():
            break
        try:
            item = queue.get(timeout=20)
        except queue_module.Empty:
            continue

        if item is None:
            break

        if mode == 'production':
            archive_path, procedure_path = item
            print(f'[INFO] Got archive: {archive_path}')
            print(f'[INFO] Got proc: {procedure_path}')
            main(
                output_dir_root,
                overwrite,
                stop_event,
                archive_path=archive_path,
                procedure_path=procedure_path,
            )
        else:
            main(output_dir_root, overwrite, stop_event, src_path=item)


def main(
    output_dir_root: Path,
    overwrite: bool,
    stop_event,
    src_path: Path | None = None,
    archive_path: Path | None = None,
    procedure_path: Path | None = None,
):
    logger = logging.getLogger(__name__)
    is_production = archive_path is not None and procedure_path is not None
    is_development = src_path is not None
    extracted_dir = None
    output_json_dir = None
    try:
        if is_production:
            ### check if already processed
            doc_id = generate_sha256(str(archive_path))
            extracted_dir = get_output_dir(doc_id, output_dir_root)
            output_json_dir = extracted_dir / 'json'
            if overwrite is False and extracted_dir.exists():
                logger.info(
                    f'[SKIP] doc_id={doc_id}, archive_path={archive_path}',
                    extra={'archive_path': str(archive_path), 'doc_id': doc_id},
                )
                return
            if overwrite is True and extracted_dir.exists():
                shutil.rmtree(extracted_dir)

            extracted_dir.mkdir(parents=True, exist_ok=True)
            if stop_event.is_set():
                logger.info(
                    f'[INTERRUPTED] doc_id={doc_id}, archive_path={archive_path}',
                    extra={'archive_path': str(archive_path), 'doc_id': doc_id},
                )
                if extracted_dir and extracted_dir.exists():
                    shutil.rmtree(extracted_dir)
                return

            ### OCR 対象は other-imagesだけ。
            ### other-images は 外国語書面出願、被引用文献 で使われる画像
            parse_archive(
                str(archive_path),
                str(procedure_path),
                str(extracted_dir),
                image_params=image_params,
                ocr_target=['other-images'],
            )
        elif is_development:
            extracted_dir = src_path
            mp = src_path / 'manifest.json'
            if not mp.exists():
                logger.info(
                    f'[SKIP] src_path={src_path} manifest.json not found.',
                    extra={'src_path': str(src_path)},
                )
                return
            doc_id = get_doc_id(str(mp))
            if not doc_id:
                logger.info(
                    f'[SKIP] src_path={src_path} doc_id not found in manifest.json.',
                    extra={'src_path': str(src_path)},
                )
                return
            print(f'[INFO] doc_id={doc_id} src_path={src_path}')

            copy_to = get_output_dir(doc_id, output_dir_root)
            ## in development mode, copy the input directory to the output directory excluding the json directory
            shutil.copytree(
                src_path,
                copy_to,
                dirs_exist_ok=overwrite,
                ignore=shutil.ignore_patterns('json/*'),
            )
            ## set output_json_dir to the json directory in the copied directory
            output_json_dir = copy_to / 'json'
        else:
            raise ValueError(
                'Either archive_path and procedure_path or src_path must be provided.'
            )

        parse(extracted_dir, output_json_dir)
        if is_production:
            logger.info(
                f'[SUCCESS] doc_id={doc_id}, archive_path={archive_path}, output={output_json_dir}',
                extra={
                    'archive_path': str(archive_path),
                    'doc_id': doc_id,
                    'output': str(output_json_dir),
                },
            )
        elif is_development:
            logger.info(
                f'[SUCCESS] src_path={src_path}, output={output_json_dir}',
                extra={'src_path': str(src_path), 'output': str(output_json_dir)},
            )
    except Exception as e:
        logger.info(
            f'[FAIL] archive_path={archive_path}, src_path={src_path} error={traceback.format_exc()}',
            extra={
                'archive_path': str(archive_path),
                'src_path': str(src_path),
                'traceback': traceback.format_exc(),
            },
        )
        if is_production:
            if extracted_dir and extracted_dir.exists():
                shutil.rmtree(extracted_dir)


def get_output_dir(doc_id: str, base_dir: Path) -> Path:
    """Convert document ID to directory path."""
    p = Path(compute_path(doc_id))
    return base_dir.joinpath(p)


if __name__ == '__main__':
    multi_processes_parent(**get_args())
