import argparse
import glob
import json
import os
import re
import shutil
import sys
from itertools import chain
from pathlib import Path
from tempfile import TemporaryDirectory
from typing import Generator

from libefiling import parse_archive
from libefiling.archive.utils import detect_document_id
from libefiling.manifest.model import Manifest

from mona.xml_pkg.merge import merge_xml


def find_procedure_xml(archive_path: Path) -> Path:
    """Find the corresponding procedure XML file for the given archive."""
    with_name = re.sub(r"AAA$", "AFM", archive_path.stem)
    xml_path = archive_path.with_name(with_name).with_suffix(".XML")
    if not xml_path.exists():
        raise FileNotFoundError(f"Procedure XML not found for archive: {archive_path}")
    return xml_path

def find_archives_in_directory(directory: str) -> Generator[tuple[Path, Path], None, None]:
    """Find all e-filing archives in the specified directory."""
    for file in chain(Path(directory).rglob("*.JWX"), Path(directory).rglob("*.JPC")):
        if re.match(r".+AAA$", file.stem) is None:
            continue
        procedure = find_procedure_xml(file)
        yield file, procedure

def extract_archive(archive_path: Path, procedure_path: Path, output_dir: Path):
    """Extract e-filing archive to the specified output directory."""
    with TemporaryDirectory() as temp_dir:
        ### Parse the archive into the temporary directory
        parse_archive(
            str(archive_path),
            str(procedure_path),
            temp_dir,
        )

        ### Read the manifest to get the document ID
        with open(os.path.join(temp_dir, "manifest.json"), "r", encoding="utf-8") as f:
            manifest_data = Manifest.model_validate_json(f.read())
    
        ### Move the parsed files to the final destination
        if not output_dir.exists():
            output_dir.mkdir(parents=True, exist_ok=True)
        else:
            raise FileExistsError(f"Directory {output_dir} already exists.")
        shutil.copytree(temp_dir, output_dir, dirs_exist_ok=True)
    return manifest_data

def id2dir(doc_id: str, base_dir: Path) -> Path:
    """Convert document ID to directory path."""
    return base_dir.joinpath(doc_id[0:2], doc_id[2:4], doc_id)

if __name__ == "__main__":
    argparse = argparse.ArgumentParser(
        description="Batch parse e-filing archives in a directory"
    )
    argparse.add_argument(
        "src_dir", type=str, help="Directory containing e-filing archives"
    )
    argparse.add_argument(
        "output_dir", type=str, help="Directory to store parsed output"
    )
    args = argparse.parse_args()

    src_dir = Path(args.src_dir)
    output_dir_root = Path(args.output_dir)
    if not src_dir.exists():
        print(f"Source directory {args.src_dir} does not exist.")
        sys.exit(1)
    if not output_dir_root.exists():
        print(f"Output directory {args.output_dir} does not exist.")
        sys.exit(1)

    for archive_path, procedure_path in find_archives_in_directory(src_dir):
        print(f"Processing archive: {archive_path}")
        print(f"Using procedure XML: {procedure_path}")

        doc_id = detect_document_id(str(archive_path))
        output_dir = id2dir(doc_id, output_dir_root)
        if output_dir.exists():
            print(f"  Output directory {output_dir} already exists. Skipping.")
            continue

        try:
            manifest_data = extract_archive(archive_path, procedure_path, output_dir)
            print(f"  Extracted to: {output_dir}")
            xml_files = (output_dir / manifest_data.paths.xml_dir).glob("*.XML", case_sensitive=False)
            merge_xml(xml_files, str(output_dir / "document.xml"))
            print(f"  Merged XML created at: {output_dir / 'document.xml'}")

        except FileExistsError as fee:
            print(f"Skipping extracting {archive_path}: {fee}")
        except Exception as e:
            print(f"Failed to extract {archive_path}: {e}")
            
