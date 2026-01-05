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
from typing import Generator, List

from libefiling import parse_archive
from libefiling.archive.utils import detect_document_id
from libefiling.manifest.model import Manifest

from mona.default_config import (
    FileKind,
    default_image_params,
    default_translator_config,
)
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

def extract_archive(archive_path: Path, procedure_path: Path, output_dir: Path, image_params):
    """Extract e-filing archive to the specified output directory."""
    if not output_dir.exists():
        output_dir.mkdir(parents=True, exist_ok=True)

    ### Parse the archive into output_dir
    parse_archive(
        str(archive_path),
        str(procedure_path),
        str(output_dir),
    )

def id2dir(doc_id: str, base_dir: Path) -> Path:
    """Convert document ID to directory path."""
    return base_dir.joinpath(doc_id[0:2], doc_id[2:4], doc_id)

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

from mona.default_config import (
    ManifestProcessor,
    MetadataProcessor,
    OCRProcessor,
    XSLTProcessor,
    default_translator_config,
)

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
            extract_archive(archive_path, procedure_path, output_dir, default_image_params)
            print(f"  Extracted to: {output_dir}")

            ### Read the manifest
            with open(os.path.join(output_dir, "manifest.json"), "r", encoding="utf-8") as f:
                manifest_data = Manifest.model_validate_json(f.read())
            
            manifest_path = output_dir / "manifest.json"
            processors: List[ManifestProcessor] = [MetadataProcessor(manifest_path), OCRProcessor(manifest_path), XSLTProcessor(manifest_path, default_translator_config)]
            data = []
            for p in processors:
                translated_data = p.translate()
                data.extend(translated_data)
            
            merged_dict = merge_dicts(data) 
            dst_path = output_dir / f"document.json"
            with open(dst_path, "w", encoding="utf-8") as f:
                json.dump(merged_dict, f, ensure_ascii=False, indent=2)
                print(f"  Generated {dst_path}")

        except FileExistsError as fee:
            print(f"Skipping extracting {archive_path}: {fee}")
        except Exception as e:
            print(f"Failed to extract {archive_path}: {e}")
            output_dir.rmdir()  # Clean up partial output
            
