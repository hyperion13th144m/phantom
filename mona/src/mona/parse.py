import json
import shutil
from itertools import chain
from pathlib import Path
from tempfile import TemporaryDirectory

from .archive.extract import extract
from .charset.convert import convert_xml_charset_dir
from .default_config import FileKind, default_translator_config, defaultImageParams
from .image.convert import convert_images
from .image.params import ImageConvertParam
from .metadata.get_metadata import get_metadata
from .ocr.ocr import guess_language, ocr_images
from .xml_pkg.merge import merge_xml
from .xml_pkg.procedure_xml import convert_procedure_xml
from .xml_pkg.translate import translate_to_json
from .xml_pkg.translation.factory import get_translators


def parse_archive(
    src_archive_path: str,
    src_procedure_path: str,
    output_dir: str,
    image_params: list[ImageConvertParam] = defaultImageParams,
    debug: bool = False,
):
    """parse e-filing archive and generate various outputs."""

    if not Path(src_archive_path).exists():
        raise FileNotFoundError(f"Source archive not found: {src_archive_path}")
    if not Path(src_procedure_path).exists():
        raise FileNotFoundError(f"Source procedure XML not found: {src_procedure_path}")
    if not Path(output_dir).exists():
        Path(output_dir).mkdir(parents=True, exist_ok=True)

    with TemporaryDirectory(delete=not debug) as temp_dir, TemporaryDirectory(
        delete=not debug
    ) as temp_dir2:
        if debug:
            print(f"Temporary dir: {temp_dir}")
            print(f"Temporary XML dir: {temp_dir2}")

        ### extract archive to temp_dir
        extract(src_archive_path, temp_dir)

        ### convert charset of all xml files in temp_dir to UTF-8 and save to temp_xml_dir
        convert_xml_charset_dir(temp_dir, temp_dir2)

        ### convert charset of procedure xml to UTF-8 and save to temp_xml_dir
        convert_procedure_xml(
            src_procedure_path,
            FileKind.PROCEDURE_XSL.value,
            f"{temp_dir2}/procedure.xml",
        )

        ### convert images
        src_images = chain(
            Path(temp_dir).glob("*.tif", case_sensitive=False),
            Path(temp_dir).glob("*.jpg", case_sensitive=False),
        )
        result = convert_images(src_images, output_dir, image_params)

        ### save conversion results as XML
        result.save_as_xml(f"{temp_dir2}/conversion_results.xml")

        ### merge all xml files in temp_xml_dir into a single xml file
        src_xmls = Path(temp_dir2).glob("*.xml", case_sensitive=False)
        dst_xml = f"{temp_dir2}/{FileKind.MERGED_XML.value}"
        merge_xml(src_xmls, dst_xml)

        ### perform OCR on images and save results as JSON
        src_images = chain(
            Path(temp_dir).glob("*.tif", case_sensitive=False),
            Path(temp_dir).glob("*.jpg", case_sensitive=False),
        )
        lang = guess_language(f"{temp_dir2}/{FileKind.MERGED_XML.value}")
        ocr_result = ocr_images(src_images, lang=lang)
        ocr_result.save_as_json(f"{temp_dir2}/{FileKind.OCR_JSON.value}")

        ### generate and save metadata as JSON
        metadata = get_metadata(src_archive_path)
        metadata.save_as_json(f"{temp_dir2}/{FileKind.METADATA_JSON.value}")

        translators = get_translators(temp_dir2, default_translator_config)

        ### translate XML to various formats and save them
        dst_path = Path(output_dir) / FileKind.DOCUMENT_JSON.value
        doc_dict = translate_to_json(translators)

        with open(dst_path, "w", encoding="utf-8") as f:
            json.dump(doc_dict, f, ensure_ascii=False, indent=2)

        ### copy merged XML to output_dir for reference
        shutil.copy(f"{temp_dir2}/{FileKind.MERGED_XML.value}", output_dir)
