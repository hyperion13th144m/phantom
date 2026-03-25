import argparse
import shutil
import sys
import traceback
from pathlib import Path
from typing import Generator, List

from libefiling import get_doc_id, get_document_code

from crow.crawler.config import get_all_document_codes, get_target_document_codes
from crow.crawler.parse import parse

# docker コンテナ起動時に /test-data-src, /test-data-dst に
# 実データがあるディレクトリがマウントされるので、決め打ちで良い。
SRC_DIR = "/test-data-src"
DATA_DIR = "/test-data-dst"


def get_args() -> dict:
    p = argparse.ArgumentParser(
        description="An application for parsing XML handled by the Internet Application Software."
    )
    p.add_argument(
        "-c",
        "--doc-code",
        nargs="+",
        choices=get_all_document_codes(),
        help="document codes to parse",
    )
    p.add_argument(
        "-o", "--overwrite", action="store_true", help="Overwrite existing output"
    )
    args = p.parse_args()

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

    return {
        "src_dir": src_dir,
        "output_dir_root": output_dir_root,
        "doc_code": get_target_document_codes(args.doc_code),
    }


def find_extracted_directories(
    directory: str, doc_codes: list[str]
) -> Generator[Path, None, None]:
    """Find all extracted archive directories contains manifest.json."""
    for m in Path(directory).rglob("manifest.json"):
        doc_code = get_document_code(str(m))
        if doc_code in doc_codes:
            yield m.parent


def main(
    src_dir: Path,
    output_dir_root: Path,
    doc_code: List[str],
):
    for item in find_extracted_directories(str(src_dir), doc_code):
        convert(
            item,
            output_dir_root,
        )


def convert(
    src_path: Path,
    output_dir_root: Path,
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
        ...
    """

    extracted_dir = None
    output_json_dir = None
    try:
        extracted_dir = src_path
        mp = src_path / "manifest.json"
        doc_id = get_doc_id(str(mp))
        if not doc_id:
            print(
                f"[SKIP] src_path={src_path} doc_id not found in manifest.json.",
            )
            return

        copy_to = get_output_dir(doc_id, output_dir_root)
        shutil.copytree(
            src_path,
            copy_to,
            dirs_exist_ok=True,
            ignore=shutil.ignore_patterns("json/*"),
        )

        ## set output_json_dir to the json directory in the copied directory
        output_json_dir = copy_to / "json"
        parse(extracted_dir, output_json_dir)
        print(
            f"[SUCCESS] src_path={src_path}, output={output_json_dir}",
        )
    except Exception:
        print(
            f"[FAIL] src_path={src_path} error={traceback.format_exc()}",
        )


def get_output_dir(doc_id: str, base_dir: Path) -> Path:
    """Convert document ID to directory path."""
    return base_dir / f"{doc_id[0:2]}/{doc_id[2:4]}/{doc_id}"


if __name__ == "__main__":
    main(**get_args())
