import argparse
import logging
import sys
from pathlib import Path

from crow.crawler.config import doc_code_config
from crow.crawler.crawler import crawl
from crow.logger import setup_cli_logger

setup_cli_logger("INFO")
logger = logging.getLogger("crow.cli")

SRC_DIR = "/src-dir"
DATA_DIR = "/data-dir"


def get_args() -> dict:
    p = argparse.ArgumentParser(
        description="An application for parsing XML handled by the Internet Application Software."
    )
    p.add_argument(
        "-s",
        "--src-dir",
        default=SRC_DIR,
        help=f"Source directory (default: {SRC_DIR})",
    )
    p.add_argument(
        "-d",
        "--data-dir",
        default=DATA_DIR,
        help=f"Output directory root (default: {DATA_DIR})",
    )
    p.add_argument(
        "-c",
        "--doc-code",
        nargs="+",
        choices=doc_code_config.get_available_codes(),
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
        doc_code_config.print()
        sys.exit(0)

    src_dir = Path(args.src_dir)
    output_dir_root = Path(args.data_dir)
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
        "doc_code": doc_code_config.get_codes(args.doc_code),
        "overwrite": args.overwrite,
        "max_files": args.max_files,
        "doc_id": args.doc_id,
    }


def main():
    args = get_args()
    for s in crawl(
        str(args["src_dir"]),
        str(args["output_dir_root"]),
        overwrite=args["overwrite"],
        doc_codes=args["doc_code"],
        max_files=args["max_files"],
        doc_id=args["doc_id"],
    ):
        logger.info(
            f"[{s.status}] doc_id={s.doc_id}, archive_path={s.archive_path}, "
            f"output={s.output_json_dir}, error_message={s.error_message or ''}",
        )


if __name__ == "__main__":
    main()
