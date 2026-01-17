import argparse
import json
import logging
import shutil
import sys
import traceback
from logging import Logger
from pathlib import Path
from typing import List

from libefiling import generate_sha256, parse_archive

from mona.config import TARGET_DOCUMENT_CODES, image_params, translator_config
from mona.find_archives import find_archives
from mona.logger import setup_logger
from mona.manifest_processor.base import ManifestProcessor
from mona.manifest_processor.metadata import MetadataProcessor
from mona.manifest_processor.ocr import OCRProcessor
from mona.manifest_processor.xslt import XSLTProcessor

setup_logger()
logger = logging.getLogger(__name__)


def main():
    src_dir, output_dir_root, doc_code, log_level, multi_processors, overwrite = (
        get_args()
    )
    logger.setLevel(getattr(logging, log_level.upper(), None))

    if multi_processors > 1:
        multi_processes_parent(
            src_dir, output_dir_root, doc_code, multi_processors, log_level, overwrite
        )
    else:
        single_process(src_dir, output_dir_root, doc_code, overwrite)


def get_args() -> tuple[Path, Path, str, int, bool]:
    p = argparse.ArgumentParser(
        description="Batch parse e-filing archives in a directory"
    )
    p.add_argument("src_dir", type=str, help="Directory containing e-filing archives")
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

    return (
        src_dir,
        output_dir_root,
        args.doc_code,
        args.log_level,
        args.multi_processors,
        args.overwrite,
    )


def single_process(
    src_dir: Path, output_dir_root: Path, doc_code: List[str], overwrite: bool
):
    for archive_path, procedure_path in find_archives(src_dir, doc_code):
        common_processing_steps(
            archive_path, procedure_path, output_dir_root, overwrite
        )


def multi_processes_parent(
    src_dir: Path,
    output_dir_root: Path,
    doc_code: List[str],
    num_processors: int,
    log_level: str,
    overwrite: bool,
):
    from multiprocessing import Process, Queue

    queue = Queue()
    processes: List[Process] = []

    # create and initialize processes
    for _ in range(num_processors):
        p = Process(
            target=multi_processes_child,
            args=(output_dir_root, queue, log_level),
        )
        p.start()
        processes.append(p)

    try:
        # give archive to each processes via queue
        for item in find_archives(src_dir, doc_code):
            queue.put(item)

        # give None for quit processes
        for _ in range(num_processors):
            queue.put(None)

    except KeyboardInterrupt:
        for p in processes:
            p.terminate()
    finally:
        # wait for all processes
        for p in processes:
            p.join()


def multi_processes_child(output_dir_root, queue, log_level, overwrite: bool):
    logger.setLevel(getattr(logging, log_level.upper(), None))
    while True:
        item = queue.get()
        if item is None:
            break
        archive_path, procedure_path = item

        common_processing_steps(
            archive_path, procedure_path, output_dir_root, overwrite
        )


def common_processing_steps(
    archive_path: Path,
    procedure_path: Path,
    output_dir_root: Path,
    overwrite: bool,
):
    ### check if already processed
    doc_id = generate_sha256(str(archive_path))
    output_dir = get_output_dir(doc_id, output_dir_root)
    if overwrite is False and output_dir.exists():
        logger.info(
            f"  Output directory {output_dir}, {archive_path} already exists. Skipping."
        )
        return
    if overwrite is True and output_dir.exists():
        pass
        # shutil.rmtree(output_dir)

    output_dir.mkdir(parents=True, exist_ok=True)
    try:
        process_archive(archive_path, procedure_path, output_dir, logger)
    except KeyboardInterrupt:
        logger.info("Process interrupted by user.")
        logger.debug(f"doc_id: {doc_id}")
        shutil.rmtree(output_dir)
        sys.exit(0)
    except Exception as e:
        logger.info(f"Failed to process {archive_path}: {e}")
        logger.debug(f"doc_id: {doc_id}")
        logger.info(traceback.format_exc())
        # shutil.rmtree(output_dir)


def process_archive(
    archive_path: Path, procedure_path: Path, output_dir: Path, logger: Logger
):
    logger.info(f"Processing archive: {archive_path}")

    ### Parse the archive into output_dir
    parse_archive(
        str(archive_path),
        str(procedure_path),
        str(output_dir),
        image_params=image_params,
    )

    manifest_path = output_dir / "manifest.json"
    data = get_data(manifest_path)
    dst_path = output_dir / f"document.json"
    with open(dst_path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        logger.info(f"  Generated {dst_path}")


def get_output_dir(doc_id: str, base_dir: Path) -> Path:
    """Convert document ID to directory path."""
    return base_dir.joinpath(doc_id[0:2], doc_id[2:4], doc_id)


def get_data(manifest_path: Path) -> dict:
    """read manifest and translate to data dict."""
    processors: List[ManifestProcessor] = [
        MetadataProcessor(manifest_path),
        XSLTProcessor(manifest_path, translator_config),
        OCRProcessor(manifest_path),
    ]
    data = []
    for p in processors:
        translated_data = p.translate()
        data.extend(translated_data)

    merged_dict = merge_dicts(data)
    return merged_dict


def merge_dicts(dicts: list[dict]) -> dict:
    """Merge a list of dicts into a single dict."""

    result = {}
    for d in dicts:
        if "root" not in d:
            continue
        for key in d["root"]:
            if key in result:
                ### key が既に存在する場合は、リストに追加する
                if isinstance(result[key], list):
                    result[key].extend(d["root"][key])
                else:
                    result[key] = [result[key]] + d["root"][key]
            else:
                ### key が存在しない場合は、新規に追加する
                result[key] = d["root"][key]

    return result


if __name__ == "__main__":
    main()
