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

from libefiling import generate_sha256

from mona.config import TARGET_DOCUMENT_CODES
from mona.find_archives import find_archives
from mona.logger import setup_child_logging, setup_logger
from mona.parse import parse


def get_args() -> dict:
    p = argparse.ArgumentParser(
        description="An application for parsing XML handled by the Internet Application Software."
    )
    p.add_argument("src_dir", type=str, help="Directory containing archives")
    p.add_argument("output_dir", type=str, help="Directory to store parsed output")
    p.add_argument(
        "doc_code",
        nargs="+",
        choices=TARGET_DOCUMENT_CODES,
        help="document codes to parse",
    )
    p.add_argument(
        "-l",
        "--log_level",
        type=str,
        choices=["info", "debug"],
        default="info",
        help="Logging level",
    )
    p.add_argument(
        "-m",
        "--multi-processors",
        type=int,
        choices=[1, 2, 3, 4],
        default=1,
        help="Number of processors to use",
    )
    p.add_argument(
        "-o", "--overwrite", action="store_true", help="Overwrite existing output"
    )
    args = p.parse_args()

    src_dir = Path(args.src_dir)
    output_dir_root = Path(args.output_dir)
    if not src_dir.exists():
        print(f"Source directory {args.src_dir} does not exist.")
        sys.exit(1)
    if not output_dir_root.exists():
        print(f"Output directory {args.output_dir} does not exist.")
        sys.exit(1)

    return {
        "src_dir": src_dir,
        "output_dir_root": output_dir_root,
        "doc_code": args.doc_code,
        "log_level": args.log_level,
        "num_processors": args.multi_processors,
        "overwrite": args.overwrite,
    }


def multi_processes_parent(
    src_dir: Path,
    output_dir_root: Path,
    doc_code: List[str],
    log_level: str,
    overwrite: bool,
    num_processors: int,
):

    queue = Queue()
    stop_event = Event()
    processes: List[Process] = []
    log_queue, listener = setup_logger(log_level=log_level)

    for _ in range(num_processors):
        p = Process(
            target=multi_processes_child,
            args=(output_dir_root, queue, log_queue, log_level, overwrite, stop_event),
        )
        p.start()
        processes.append(p)

    try:
        # give archive to each processes via queue
        for item in find_archives(str(src_dir), doc_code):
            if stop_event.is_set():
                break
            queue.put(item)

        # 正常終了ルート：sentinel投入
        for _ in range(num_processors):
            queue.put(None)

    except KeyboardInterrupt:
        stop_event.set()

        # 子がqueue.getから抜けられるようにsentinelも投げる（重要）
        for _ in range(num_processors):
            queue.put(None)

        # “穏当停止”を少し待つ
        deadline = time.time() + 5
        for p in processes:
            remaining = max(0, deadline - time.time())
            p.join(timeout=remaining)

        # まだ残ってたら強制停止
        for p in processes:
            if p.is_alive():
                p.terminate()
    finally:
        # wait for all processes
        for p in processes:
            p.join()
        listener.stop()


def multi_processes_child(
    output_dir_root, queue, log_queue, log_level, overwrite: bool, stop_event
):
    setup_child_logging(log_queue, log_level)
    while True:
        if stop_event.is_set():
            break
        try:
            item = queue.get(timeout=0.5)
        except queue_module.Empty:
            continue

        if item is None:
            break

        archive_path, procedure_path = item
        main(
            archive_path,
            procedure_path,
            output_dir_root,
            overwrite,
            stop_event,
        )


def main(
    archive_path: Path,
    procedure_path: Path,
    output_dir_root: Path,
    overwrite: bool,
    stop_event,
):
    logger = logging.getLogger(__name__)

    ### check if already processed
    doc_id = generate_sha256(str(archive_path))
    output_dir = get_output_dir(doc_id, output_dir_root)
    if overwrite is False and output_dir.exists():
        logger.info(
            f"[SKIP] doc_id={doc_id}, archive_path={archive_path}",
            extra={"archive_path": str(archive_path), "doc_id": doc_id},
        )
        return
    if overwrite is True and output_dir.exists():
        shutil.rmtree(output_dir)

    output_dir.mkdir(parents=True, exist_ok=True)
    try:
        if stop_event.is_set():
            logger.info(
                f"[INTERRUPTED] doc_id={doc_id}, archive_path={archive_path}",
                extra={"archive_path": str(archive_path), "doc_id": doc_id},
            )
            shutil.rmtree(output_dir)
            sys.exit(0)
        parse(archive_path, procedure_path, output_dir)
        logger.info(
            f"[SUCCESS] doc_id={doc_id}, archive_path={archive_path}",
            extra={"archive_path": str(archive_path), "doc_id": doc_id},
        )
    except Exception as e:
        logger.info(
            f"[FAIL] doc_id={doc_id}, archive_path={archive_path}, error={traceback.format_exc()}",
            extra={
                "archive_path": str(archive_path),
                "doc_id": doc_id,
                "traceback": traceback.format_exc(),
            },
        )
        shutil.rmtree(output_dir)


def get_output_dir(doc_id: str, base_dir: Path) -> Path:
    """Convert document ID to directory path."""
    return base_dir.joinpath(doc_id[0:2], doc_id[2:4], doc_id)


if __name__ == "__main__":
    multi_processes_parent(**get_args())
