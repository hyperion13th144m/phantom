from enum import Enum
from typing import List

from libefiling.image.params import ImageConvertParam

from .xml_pkg.translation.factory import TranslatorConfig

SCHEMA_VER = "1.0"


class FileKind(Enum):
    MERGED_XML = "document.xml"
    METADATA_JSON = "metadata.json"
    OCR_JSON = "ocr_results.json"
    DOCUMENT_JSON = "document.json"
    PROCEDURE_XSL = f"{SCHEMA_VER}/procedure.xsl"


default_image_params: list[ImageConvertParam] = [
    {
        "width": 300,
        "height": 300,
        "suffix": "-thumbnail",
        "format": ".webp",
        "attributes": [{"key": "sizeTag", "value": "thumbnail"}],
    },
    {
        "width": 600,
        "height": 600,
        "suffix": "-middle",
        "format": ".webp",
        "attributes": [{"key": "sizeTag", "value": "middle"}],
    },
    {
        "width": 800,
        "height": 0,
        "suffix": "-large",
        "format": ".webp",
        "attributes": [{"key": "sizeTag", "value": "large"}],
    },
]


default_translator_config: List[TranslatorConfig] = [
    {
        ### 書誌情報の各項目のテキスト. 検索用
        "xsl_path": f"{SCHEMA_VER}/bibliographic.xsl",
        "force_list": None,
        "namespace": "",
        "doctype": "procedure-params",
    },
    ### A163 日本語特許出願関連
    {
        ### 願書 テキストブロック SSG用
        "xsl_path": f"{SCHEMA_VER}/pat-appd.xsl",
        "force_list": ["blocks"],
        "namespace": "http://www.jpo.go.jp",
        "doctype": "pat-app-doc",
    },
    {
        ### 明細書 テキストブロック SSG用
        "xsl_path": f"{SCHEMA_VER}/application-body.xsl",
        "force_list": ["blocks"],
        "namespace": "",
        "doctype": "application-body",
    },
    ### A163 外国語書面出願
    {
        ### 明細書 テキストブロック SSG用
        "xsl_path": f"{SCHEMA_VER}/foreign-language-body.xsl",
        "force_list": ["blocks"],
        "namespace": "http://www.jpo.go.jp",
        "doctype": "foreign-language-body",
    },
    {
        ### 画像情報
        "xsl_path": f"{SCHEMA_VER}/images.xsl",
        "force_list": ["blocks", "image"],
        "namespace": "",
        "doctype": "images",
    },
]

import re
from abc import ABC, abstractmethod
from pathlib import Path

from libefiling.archive.utils import detect_document_extension, detect_document_kind
from libefiling.manifest.model import Manifest


class ManifestProcessor(ABC):
    def __init__(self, manifest_path: Path):
        self.manifest_dir = manifest_path.parent
        with open(manifest_path, "r", encoding="utf-8") as f:
            self.manifest = Manifest.model_validate_json(f.read())

    @abstractmethod
    def translate(self) -> list[dict]:
        pass

class MetadataProcessor(ManifestProcessor):
    def translate(self) -> list[dict]:
        data = {"root": {
            "docId": self.manifest.document.doc_id,
            "archive": self.manifest.document.source.archive_filename,
            "procedure": self.manifest.document.procedure_source.procedure_filename,
            "schemaVer": SCHEMA_VER,
            "ext": detect_document_extension(self.manifest.document.source.archive_filename),
            "kind": detect_document_kind(self.manifest.document.source.archive_filename),
        }}
        return [data]

class OCRProcessor(ManifestProcessor):
    def translate(self) -> list[dict]:
        ocr_results = []
        ocr_files = [image.ocr.path for image in self.manifest.images]
        for ocr_file in ocr_files:
            ocr_path = self.manifest_dir / ocr_file
            with open(ocr_path, "r", encoding="utf-8") as f:
                text = f.read()
            ocr_results.append(re.sub(r"\s+", " ", text).strip())
        return [{"root": {"ocrText": "".join(ocr_results)}}]
 
import xmltodict

from .xml_pkg.translation.resolver import xsl_resolver
from .xml_pkg.translation.subr import translate_xml


class XSLTProcessor(ManifestProcessor):
    def __init__(self, manifest_path: Path, translator_config: List[TranslatorConfig]):
        super().__init__(manifest_path)
        self.translator_config = translator_config

    def translate(self) -> list[dict]:
        data = []
        xml_files = [self.manifest_dir /xml_file.path for xml_file in self.manifest.xml_files]
        merged_xml_string = self.merge_xml_files(xml_files)
        
        for config in self.translator_config:
            if self.has_doctype(
                xml_string=merged_xml_string,
                namespace=config["namespace"],
                doctype=config["doctype"],
            ) is False:
                continue
            
            translated_xml = translate_xml(
                src_xml=merged_xml_string,
                xsl_name=xsl_resolver(config["xsl_path"])
            )
            translated_data = xmltodict.parse(
                translated_xml,
                strip_whitespace=False,
                force_list=config["force_list"] if config["force_list"] else [],
            )
            data.append(translated_data)

        return data

    def merge_xml_files(self, xml_files: list[Path]):
        from .xml_pkg.merge import merge_xml_to_string
        return merge_xml_to_string(iter(xml_files))

    def has_doctype(self, xml_string: str, namespace: str, doctype: str) -> bool:
        import xml.etree.ElementTree as ET

        root = ET.fromstring(xml_string)
        if namespace:
            search_tag = f"{{{namespace}}}{doctype}"
        else:
            search_tag = doctype

        return root.find(search_tag) is not None