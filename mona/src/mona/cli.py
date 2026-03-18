import argparse
import logging
import shutil
import sys
import traceback
from pathlib import Path
from typing import List

from libefiling import generate_sha256, get_doc_id, parse_archive

from mona.compute_path import compute_path
from mona.config import TARGET_DOCUMENT_CODES, image_params
from mona.find_archives import find_archives, find_extracted_directories
from mona.logger import setup_logger
from mona.parse import parse

setup_logger()
logger = logging.getLogger("mona.cli")


def get_args() -> dict:
    p = argparse.ArgumentParser(
        description="An application for parsing XML handled by the Internet Application Software."
    )
    p.add_argument("src_dir", type=str, help="Directory containing archives")
    p.add_argument(
        "output_dir",
        type=str,
        help="Directory to store parsed output in production mode.",
    )
    p.add_argument(
        "doc_code",
        nargs="+",
        choices=TARGET_DOCUMENT_CODES,
        help="document codes to parse",
    )
    p.add_argument(
        "-o", "--overwrite", action="store_true", help="Overwrite existing output"
    )
    p.add_argument(
        "--mode",
        choices=["production", "development"],
        default="production",
        help="Enable production mode",
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
        "overwrite": args.overwrite,
        "mode": args.mode,
    }


def main(
    src_dir: Path,
    output_dir_root: Path,
    doc_code: List[str],
    overwrite: bool,
    mode: str,
):

    if mode == "production":
        for item in find_archives(str(src_dir), doc_code):
            archive_path, procedure_path = item
            main_in_production_mode(
                archive_path, procedure_path, output_dir_root, overwrite
            )
    elif mode == "development":
        for item in find_extracted_directories(str(src_dir), doc_code):
            main_in_development_mode(
                item,
                output_dir_root,
                overwrite,
            )
    else:
        logger.info(f'Invalid mode: {mode}. Use "production" or "development".')


def main_in_production_mode(
    archive_path: Path, procedure_path: Path, output_dir_root: Path, overwrite: bool
):
    """Run the main processing logic in production mode.
    production mode processes each pairs of archives and procedure xml files,
    and saves the output in the output directory.
    """

    extracted_dir = None
    output_json_dir = None
    try:
        ### check if already processed
        doc_id = generate_sha256(str(archive_path))
        extracted_dir = get_output_dir(doc_id, output_dir_root)
        output_json_dir = extracted_dir / "json"
        if overwrite is False and extracted_dir.exists():
            logger.info(
                f"[SKIP] doc_id={doc_id}, archive_path={archive_path}",
            )
            return
        if overwrite is True and extracted_dir.exists():
            shutil.rmtree(extracted_dir)

        extracted_dir.mkdir(parents=True, exist_ok=True)

        ### OCR 対象は other-imagesだけ。
        ### other-images は 外国語書面出願、被引用文献 で使われる画像
        parse_archive(
            str(archive_path),
            str(procedure_path),
            str(extracted_dir),
            image_params=image_params,
            ocr_target=["other-images"],
            image_max_workers=0,
        )

        parse(extracted_dir, output_json_dir)
        logger.info(
            f"[SUCCESS] doc_id={doc_id}, archive_path={archive_path}, output={output_json_dir}",
        )
    except Exception:
        logger.info(
            f"[FAIL] archive_path={archive_path}, error={traceback.format_exc()}",
        )
        if extracted_dir and extracted_dir.exists():
            shutil.rmtree(extracted_dir)


def main_in_development_mode(
    src_path: Path,
    output_dir_root: Path,
    overwrite: bool,
):
    """Run the main processing logic in development mode.
    development mode processes each directories that contains files extracted by libefiling.parse_archive.
    this function processes as follows,
      0. direcory structure
        directoreis
        ├── images
        │   └── *.webp
        ├── manifest.json
        ├── ocr
        │   └── *.txt
        ├── raw
        │   └── *.*
        └── xml
            └── *.xml
      1. copy all under output_dir_root
        output_dir_root
        └── 00
        └── 01
        └── f'{doc_id}' (from manifes.json)
                    ├── images
                    │   └── *.webp
                    ├── manifest.json
                    ├── ocr
                    │   └── *.txt
                    ├── raw
                    │   └── *.*
                    └── xml
                        └── *.xml
      2. generate json
        f'{doc_id}' (from manifes.json)
        ├── json
        │   └── *.json
        ├── images
        │   └── *.webp
        ├── manifest.json
        ...
    """

    extracted_dir = None
    output_json_dir = None
    try:
        extracted_dir = src_path
        mp = src_path / "manifest.json"
        doc_id = get_doc_id(str(mp))
        if not doc_id:
            logger.info(
                f"[SKIP] src_path={src_path} doc_id not found in manifest.json.",
            )
            return

        copy_to = get_output_dir(doc_id, output_dir_root)
        shutil.copytree(
            src_path,
            copy_to,
            dirs_exist_ok=overwrite,
            ignore=shutil.ignore_patterns("json/*"),
        )

        ## set output_json_dir to the json directory in the copied directory
        output_json_dir = copy_to / "json"
        parse(extracted_dir, output_json_dir)
        logger.info(
            f"[SUCCESS] src_path={src_path}, output={output_json_dir}",
        )
    except Exception:
        logger.info(
            f"[FAIL] src_path={src_path} error={traceback.format_exc()}",
        )


def get_output_dir(doc_id: str, base_dir: Path) -> Path:
    """Convert document ID to directory path."""
    p = Path(compute_path(doc_id))
    return base_dir.joinpath(p)


if __name__ == "__main__":
    main(**get_args())
