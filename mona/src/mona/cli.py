import argparse
import logging
import sys
from pathlib import Path
from typing import List, Optional

from mona.crawler.config import (
    code_config,
    get_all_document_codes,
    get_target_document_codes,
)
from mona.crawler.crawler import crawl
from mona.logger import setup_logger

setup_logger()
logger = logging.getLogger("mona.cli")

# docker コンテナ起動時に /data-dir に
# 実データがあるディレクトリがマウントされるので、決め打ちで良い。
SRC_DIR = "/src-dir"
DATA_DIR = "/data-dir"


def get_args() -> dict:
    p = argparse.ArgumentParser(
        description="An application for parsing XML handled by the Internet Application Software."
    )
    p.add_argument(
        "-c",
        "--doc-code",
        choices=get_all_document_codes(),
        help="document codes to parse",
    )
    p.add_argument(
        "-o", "--overwrite", action="store_true", help="Overwrite existing output"
    )
    p.add_argument(
        "-l",
        "--log-level",
        choices=["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"],
        default="INFO",
        help="Set the logging level",
    )
    p.add_argument(
        "-m",
        "--max-files",
        type=int,
        default=None,
        help="Maximum number of files to process",
    )
    p.add_argument(
        "-i",
        "--doc-id",
        type=str,
        default=None,
        help="Process only the document with the specified doc_id (SHA256 of the archive)",
    )
    p.add_argument(
        "--print-doc-codes",
        action="store_true",
        help="Print available document codes and exit",
    )
    args = p.parse_args()

    if args.print_doc_codes:
        print_available_doc_codes()
        sys.exit(0)

    src_dir = Path(SRC_DIR)
    output_dir_root = Path(DATA_DIR)
    if not src_dir.exists():
        print(f"Source directory {src_dir} does not exist.")
        sys.exit(1)
    if not output_dir_root.exists():
        print(f"Output directory {output_dir_root} does not exist.")
        sys.exit(1)
    if args.doc_code is None:
        print(
            "No document code specified. Use -c/--doc-code to specify document codes to parse."
        )
        p.print_usage()
        sys.exit(1)

    if args.log_level:
        numeric_level = getattr(logging, args.log_level.upper(), None)
        if isinstance(numeric_level, int):
            logger.setLevel(numeric_level)
        else:
            print(f"Invalid log level: {args.log_level}")
            sys.exit(1)

    return {
        "src_dir": src_dir,
        "output_dir_root": output_dir_root,
        "doc_code": get_target_document_codes(args.doc_code),
        "overwrite": args.overwrite,
        "max_files": args.max_files,
        "doc_id": args.doc_id,
    }


def main(
    src_dir: Path,
    output_dir_root: Path,
    doc_code: List[str],
    overwrite: bool,
    max_files: Optional[int] = None,
    doc_id: Optional[str] = None,
):
    for s in crawl(
        str(src_dir),
        str(output_dir_root),
        overwrite=overwrite,
        doc_codes=doc_code,
        max_files=max_files,
        doc_id=doc_id,
    ):
        logger.info(
            f"[{s.status}] doc_id={s.doc_id}, archive_path={s.archive_path}, "
            f"output={s.output_json_dir}, error_message={s.error_message or ''}",
        )


def print_available_doc_codes():
    for category in code_config.keys():
        print(f"{category} {code_config.get(category, {}).get('description', '')}")
        for code, desc in code_config.get(category, {}).get("codes", {}).items():
            # description = code_config.get(code, {}).get("description", "")
            print(f"\t{code}: {desc}")
    print()
    print("Available document codes for doc_code:")
    print(", ".join(get_all_document_codes()))


if __name__ == "__main__":
    main(**get_args())
