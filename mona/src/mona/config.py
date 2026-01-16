from typing import List

from libefiling.image.params import ImageConvertParam

from .manifest_processor.xslt import TranslatorConfig

SCHEMA_VER = "1.0"
TARGET_DOCUMENT_CODES = ["A163", "A153", "A159"]


def postprocess_application_body(path: List[str], key: str, value: str) -> None:
    if key in ["representative", "isLastSentence", "isIndependent"]:
        return key, value.lower() == "true"
    if key in ["width", "height"]:
        if value.isdigit():
            return key, int(value)
    return key, value


image_params: list[ImageConvertParam] = [
    ImageConvertParam(
        width=300,
        height=300,
        suffix="-thumbnail",
        format=".webp",
        attributes=[{"key": "sizeTag", "value": "thumbnail"}],
    ),
    ImageConvertParam(
        width=600,
        height=600,
        suffix="-middle",
        format=".webp",
        attributes=[{"key": "sizeTag", "value": "middle"}],
    ),
    ImageConvertParam(
        width=800,
        height=0,
        suffix="-large",
        format=".webp",
        attributes=[{"key": "sizeTag", "value": "large"}],
    ),
]

translator_config = [
    ### procedure.xml テキスト
    TranslatorConfig(
        xsl_path=f"{SCHEMA_VER}/procedure.xsl",
        force_list=[],
        namespace="http://www.jpo.go.jp",
        doctype="procedure",
    ),
    TranslatorConfig(
        ### A163 日本語特許出願関連
        ### 願書 テキストブロック
        xsl_path=f"{SCHEMA_VER}/pat-appd.xsl",
        force_list=["blocks"],
        namespace="http://www.jpo.go.jp",
        doctype="pat-app-doc",
    ),
    TranslatorConfig(
        ### 明細書 テキストブロック
        xsl_path=f"{SCHEMA_VER}/application-body.xsl",
        force_list=["blocks"],
        namespace="",
        doctype="application-body",
        postprocessor=postprocess_application_body,
    ),
    TranslatorConfig(
        ### A163 外国語書面出願
        xsl_path=f"{SCHEMA_VER}/foreign-language-body.xsl",
        force_list=["blocks"],
        namespace="http://www.jpo.go.jp",
        doctype="foreign-language-body",
        postprocessor=postprocess_application_body,
    ),
    TranslatorConfig(
        ### 画像情報
        xsl_path=f"{SCHEMA_VER}/images.xsl",
        force_list=["blocks", "image"],
        namespace="",
        doctype="images",
        postprocessor=postprocess_application_body,
    ),
    TranslatorConfig(
        ### A153/A159 意見書、弁明書 テキストブロック
        xsl_path=f"{SCHEMA_VER}/pat-rspn.xsl",
        force_list=["blocks"],
        namespace="http://www.jpo.go.jp",
        doctype="pat-rspns",
    ),
]
