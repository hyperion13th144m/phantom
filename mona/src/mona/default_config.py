from enum import Enum
from typing import List

from libefiling.xml.translation.factory import TranslatorConfig

from .image.params import ImageConvertParam
from .xml_pkg.translation.translators import JSONLoader, JSONTranslator, OCRJSONLoader

SCHEMA_VER = "1.0"


class FileKind(Enum):
    MERGED_XML = "document.xml"
    METADATA_JSON = "metadata.json"
    OCR_JSON = "ocr_results.json"
    DOCUMENT_JSON = "document.json"
    PROCEDURE_XSL = f"{SCHEMA_VER}/procedure.xsl"


defaultImageParams: list[ImageConvertParam] = [
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
        ### metadata
        "translator": JSONLoader,
        "src": FileKind.METADATA_JSON.value,
        "args": {},
        "factory_args": {},
    },
    {
        ### 書誌情報の各項目のテキスト. 検索用
        "translator": JSONTranslator,
        "src": FileKind.MERGED_XML.value,
        "args": {
            "xsl_path": f"{SCHEMA_VER}/bibliographic.xsl",
            "force_list": None,
        },
        "factory_args": {
            "namespace": "",
            "doctype": "procedure-params",
        },
    },
    ### A163 日本語特許出願関連
    {
        ### 願書 テキストブロック SSG用
        "translator": JSONTranslator,
        "src": FileKind.MERGED_XML.value,
        "args": {
            "xsl_path": f"{SCHEMA_VER}/pat-appd.xsl",
            "force_list": ["blocks"],
        },
        "factory_args": {
            "namespace": "http://www.jpo.go.jp",
            "doctype": "pat-app-doc",
        },
    },
    {
        ### 明細書 テキストブロック SSG用
        "translator": JSONTranslator,
        "src": FileKind.MERGED_XML.value,
        "args": {
            "xsl_path": f"{SCHEMA_VER}/application-body.xsl",
            "force_list": ["blocks"],
        },
        "factory_args": {
            "namespace": "",
            "doctype": "application-body",
        },
    },
    ### A163 外国語書面出願
    {
        ### 明細書 テキストブロック SSG用
        "translator": JSONTranslator,
        "src": FileKind.MERGED_XML.value,
        "args": {
            "xsl_path": f"{SCHEMA_VER}/foreign-language-body.xsl",
            "force_list": ["blocks"],
        },
        "factory_args": {
            "namespace": "http://www.jpo.go.jp",
            "doctype": "foreign-language-body",
        },
    },
    {
        ### 画像情報
        "translator": JSONTranslator,
        "src": FileKind.MERGED_XML.value,
        "args": {
            "xsl_path": f"{SCHEMA_VER}/images.xsl",
            "force_list": ["blocks", "image"],
        },
        "factory_args": {
            "namespace": "",
            "doctype": "images",
        },
    },
    {
        ### ocr
        "translator": OCRJSONLoader,
        "src": FileKind.OCR_JSON.value,
        "args": {},
        "factory_args": {},
    },
]
