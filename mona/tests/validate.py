import argparse
import sys
from pathlib import Path

from pydantic import ValidationError

from mona.models.intermediate_models import GeneratedSchemaForRoot


def validate_file(file_path: Path):
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            data = f.read()
        GeneratedSchemaForRoot.model_validate_json(data)
        print(f"Validation successful for file: {file_path}")
    except ValidationError as e:
        print(f"Validation error in file: {file_path}")
        print(e)


def validate_directory(dir_path: Path):
    for file_path in dir_path.rglob("document.json"):
        validate_file(file_path)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Validate document.json")
    parser.add_argument("-f", "--src-file", type=str, help="Source file path")
    parser.add_argument("-s", "--src-dir", type=str, help="Source directory path")
    args = parser.parse_args()
    if args.src_file:
        validate_file(Path(args.src_file))
    elif args.src_dir:
        validate_directory(Path(args.src_dir))
    else:
        print("Please provide either --src-file or --src-dir argument.")
        sys.exit(1)
