"""
取り込み対象のアーカイブに関するモジュール
"""

import logging
import re
from itertools import chain
from pathlib import Path
from typing import Generator

logger = logging.getLogger(__name__)


def find_archives(
    directory: str,
    doc_codes: list[str],
) -> Generator[tuple[Path, Path], None, None]:
    """Find all e-filing archives and corresponding procedure XML files in the specified directory."""
    for file in chain(Path(directory).rglob("*.JWX"), Path(directory).rglob("*.JPC")):
        if re.match(r".+AAA$", file.stem) or re.match(r".+NNF$", file.stem):
            if len(doc_codes) == 0 or is_target_document(file, doc_codes):
                procedure = find_procedure_xml(file)
                if procedure is None:
                    logger.warning(f"Procedure XML not found for archive: {file}")
                    continue
                yield file, procedure
            else:
                logging.debug(f"Skip non-target document code: {file.name}")
        else:
            logging.debug(f"Skip non-archive file: {file.name}")


def is_target_document(document_filename: Path, doc_codes: list[str]) -> bool:
    """Check if the document code is in the target list."""
    for target in doc_codes:
        pattern = rf".+_{target}_.+"
        if re.match(pattern, document_filename.name):
            return True
    return False


def find_procedure_xml(archive_path: Path) -> Path | None:
    """Find the corresponding procedure XML file for the given archive."""
    with_name = re.sub(r"AAA$", "AFM", archive_path.stem)
    with_name = re.sub(r"NNF$", "NFM", with_name)
    xml_path = archive_path.with_name(with_name).with_suffix(".XML")
    if not xml_path.exists():
        return None
    return xml_path
