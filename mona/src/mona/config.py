from libefiling.image.params import ImageConvertParam

from .manifest_processor.xslt import TranslatorConfig

SCHEMA_VER = "1.0"
TARGET_DOCUMENT_CODES = ["A163"]


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
        ### 願書 テキストブロック SSG用
        xsl_path=f"{SCHEMA_VER}/pat-appd.xsl",
        force_list=["blocks"],
        namespace="http://www.jpo.go.jp",
        doctype="pat-app-doc",
    ),
    TranslatorConfig(
        ### 明細書 テキストブロック SSG用
        xsl_path=f"{SCHEMA_VER}/application-body.xsl",
        force_list=["blocks"],
        namespace="",
        doctype="application-body",
    ),
    TranslatorConfig(
        ### A163 外国語書面出願
        xsl_path=f"{SCHEMA_VER}/foreign-language-body.xsl",
        force_list=["blocks"],
        namespace="http://www.jpo.go.jp",
        doctype="foreign-language-body",
    ),
    TranslatorConfig(
        ### 画像情報
        xsl_path=f"{SCHEMA_VER}/images.xsl",
        force_list=["blocks", "image"],
        namespace="",
        doctype="images",
    ),
]
