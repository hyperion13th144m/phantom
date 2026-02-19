import argparse
import json
import logging
import shutil
import sys
import tempfile
import traceback
from logging import Logger
from pathlib import Path
from typing import List

from libefiling import Manifest, generate_sha256, parse_archive
from queen.translate_all import translate_all

from mona.config import TARGET_DOCUMENT_CODES, image_params
from mona.find_archives import find_archives
from mona.logger import setup_logger
from mona.manifest_processor.base import ManifestProcessor
from mona.manifest_processor.metadata import MetadataProcessor
from mona.manifest_processor.ocr import OCRProcessor

# from mona.manifest_processor.xslt import XSLTProcessor
from mona.merge_dict import deep_merge


def parse(archive_path: Path, procedure_path: Path, output_dir: Path):
    logger = logging.getLogger(__name__)
    logger.info(
        f"Processing archive",
        extra={
            "archive_path": str(archive_path),
            "procedure_path": str(procedure_path),
            "output_dir": str(output_dir),
        },
    )

    ### Parse the archive into output_dir
    parse_archive(
        str(archive_path),
        str(procedure_path),
        str(output_dir),
        image_params=image_params,
        skip_ocr=False,
    )

    manifest_path = output_dir / "manifest.json"
    manifest = Manifest.model_validate_json(manifest_path.open(encoding="utf-8").read())

    xml_files = [str(output_dir / x.path) for x in manifest.xml_files]
    json_dir = output_dir / "json"
    json_dir.mkdir(exist_ok=True)
    translate_all(src_xml=xml_files, output_dir=str(json_dir))
    # new version
    # 1. each xml file is translated to json by XSLT with a reference to the manifest
    #    pat-app-doc.json, application-body.json, etc.
    #    image-description.json, representative-image.json, etc.
    #    bib.json, fields.json
    #    using: TranslatorConfig
    #    save in working directory (not output_dir)

    process_manifest()
    # 2. generate json from manifest
    #    manifest -> metadata.json
    #    manifest -> ocr.json
    #    manifest -> image-information.json
    #    using: ManifestToJsonConfig
    #    save in working directory (not output_dir)

    merge_json()
    # 3. merge json
    #    output_dir: {doc_id}/json
    #      document.json:
    #        from metadata.json, bib.json
    #      document-blocks.json:
    #        from application-body.json, pat-app-doc.json, etc.
    #           { "root": [ {doc1}, {doc2}}]}
    #      image.json:
    #        from image-information,
    #             if exists representative-image and image-description
    #      fields.json
    #    using: MergeConfig?


def process_xml():
    pass


def process_manifest():
    pass


def merge_json():
    pass
    pass
    pass
    pass
