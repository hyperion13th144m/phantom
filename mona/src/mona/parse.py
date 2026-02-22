import tempfile
from pathlib import Path

from libefiling import Manifest, parse_archive
from queen.translate_all import DoctypePathMap, translate_all

from mona.config import image_params
from mona.manifest_processor.image_info import image_info
from mona.manifest_processor.metadata import metadata
from mona.manifest_processor.ocr import ocr

# from mona.manifest_processor.xslt import XSLTProcessor
from mona.merge_json import copy_items, merge_image_info, merge_jsons_as_array


def parse(archive_path: Path, procedure_path: Path, output_dir: Path):
    ### Parse the archive into output_dir
    ### other-images are only processed to ocr. other-images are used
    ### for foreign language documents, which are not processed to full-text, but only ocr-ed.
    ### other-images are also used for non patent documents.
    parse_archive(
        str(archive_path),
        str(procedure_path),
        str(output_dir),
        image_params=image_params,
        ocr_target=["other-images"],
    )

    manifest_path = output_dir / "manifest.json"
    manifest = Manifest.model_validate_json(manifest_path.open(encoding="utf-8").read())

    # rewrite path to manifest.json to output_dir
    manifest.paths.root = str(output_dir)

    with tempfile.TemporaryDirectory() as temp_dir:
        # final output jsons are stored in json_dir
        json_dir = output_dir / "json"
        json_dir.mkdir(exist_ok=True)

        # working directories
        work_dir = Path(temp_dir)
        doc_dir = Path(temp_dir) / "doc"
        doc_dir.mkdir(exist_ok=True)

        # setup output file names for each doctype
        bibliography_path = str(work_dir / "bibliography.json")
        full_text_path = str(work_dir / "full-text.json")
        image_desc_path = str(work_dir / "image-description.json")
        doctype_path_map: DoctypePathMap = {
            "images-description": image_desc_path,
            "bibliographic-items": bibliography_path,
            "full-text": full_text_path,
            "application-body": str(doc_dir / "application-body.json"),
            "foreign-language-body": str(doc_dir / "foreign-language-body.json"),
            "pat-app-doc": str(doc_dir / "pat-app-doc.json"),
            "pat-amnd": str(doc_dir / "pat-amnd.json"),
            "pat-rspn": str(doc_dir / "pat-rspn.json"),
            "pat-etc": str(doc_dir / "pat-etc.json"),
            "cpy-notice-pat-exam": str(doc_dir / "cpy-notice-pat-exam.json"),
            "cpy-notice-pat-exam-rn": str(doc_dir / "cpy-notice-pat-exam-rn.json"),
            "cpy-notice-pat-frm": str(doc_dir / "cpy-notice-pat-frm.json"),
        }

        # 1. translate all xml to json
        xml_dir = output_dir / manifest.paths.xml_dir
        xml_files = [str(xml_dir / x.filename) for x in manifest.xml_files]
        translate_all(src_xml=xml_files, doctype_path_map=doctype_path_map)

        # 2. generate json from manifest
        metadata_path = str(work_dir / "metadata.json")
        metadata(manifest, metadata_path)
        ocr_path = str(work_dir / "ocr.json")
        ocr(manifest, ocr_path)
        image_info_path = str(work_dir / "image-information.json")
        image_info(manifest, image_info_path)

        # 3. merge json
        copy_items(
            bibliography_path,
            {
                metadata_path: ["docId"],
                full_text_path: ["inventors", "applicants", "agents"],
            },
            str(json_dir / "bibliography.json"),
        )
        copy_items(
            full_text_path,
            {
                metadata_path: ["docId", "task", "kind"],
            },
            str(json_dir / "full-text.json"),
        )
        merge_jsons_as_array(
            [str(f) for f in doc_dir.glob("*.json")],
            str(json_dir / "document.json"),
        )
        merge_image_info(
            image_info_path,
            image_desc_path,
            ocr_path,
            str(json_dir / "images-information.json"),
        )
