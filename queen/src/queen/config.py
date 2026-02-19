from importlib import resources
from typing import Literal

from pydantic import BaseModel

SCHEMA_VER = "2.0"


def xsl_path(xsl_name: str) -> str:
    p = (
        resources.files("queen")
        .joinpath("stylesheets")
        .joinpath(SCHEMA_VER)
        .joinpath(xsl_name)
    )
    with resources.as_file(p) as f:
        return str(f)


TranslatorKey = Literal[
    "bibliography",
    "pat-app-doc",
    "application-body",
    "foreign-language-body",
    "images-information",
    "pat-amnd",
    "pat-rspn",
    "pat-etc",
    "cpy-notice-pat-exam",
    "cpy-notice-pat-exam-rn",
    "cpy-notice-pat-frm",
    "full-text",
]


class TranslatorConfigItems(BaseModel):
    xsl_path: str
    namespace: str
    doctype: str
    default_filename: str


TranslatorConfig = dict[TranslatorKey, TranslatorConfigItems]


translator_config: TranslatorConfig = {
    "bibliography": TranslatorConfigItems(
        ### procedure.xml テキスト
        xsl_path=xsl_path("procedure.xsl"),
        namespace="http://www.jpo.go.jp",
        doctype="procedure",
        default_filename="bibliography.json",
    ),
    "pat-app-doc": TranslatorConfigItems(
        ### A163 日本語特許出願関連
        ### 願書 テキストブロック
        xsl_path=xsl_path("pat-appd.xsl"),
        namespace="http://www.jpo.go.jp",
        doctype="pat-app-doc",
        default_filename="pat-app-doc.json",
    ),
    "application-body": TranslatorConfigItems(
        ### 明細書 テキストブロック
        xsl_path=xsl_path("application-body.xsl"),
        namespace="",
        doctype="application-body",
        default_filename="application-body-blocks.json",
    ),
    "foreign-language-body": TranslatorConfigItems(
        ### A163 外国語書面出願
        xsl_path=xsl_path("foreign-language-body.xsl"),
        namespace="http://www.jpo.go.jp",
        doctype="foreign-language-body",
        default_filename="foreign-language-body-blocks.json",
    ),
    # "images-information": TranslatorConfigItems(
    #    ### 画像情報
    #    xsl_path=str(XSL_DIR / "images.xsl"),
    #    namespace="",
    #    doctype="images",
    #    default_filename="images-information.json",
    # ),
    "pat-amnd": TranslatorConfigItems(
        ### A1523 手続補正書
        xsl_path=xsl_path("pat-amnd.xsl"),
        namespace="http://www.jpo.go.jp",
        doctype="pat-amnd",
        default_filename="pat-amnd-blocks.json",
    ),
    "pat-rspn": TranslatorConfigItems(
        ### A153/A159 意見書、弁明書 テキストブロック
        xsl_path=xsl_path("pat-rspn.xsl"),
        namespace="http://www.jpo.go.jp",
        doctype="pat-rspns",
        default_filename="pat-rspns-blocks.json",
    ),
    "pat-etc": TranslatorConfigItems(
        ### A1781, A871, A872 上申書, 早期審査に関する事情説明書, 早期審査に関する事情説明補充書
        xsl_path=xsl_path("pat-etc.xsl"),
        namespace="http://www.jpo.go.jp",
        doctype="pat-etc",
        default_filename="pat-etc-blocks.json",
    ),
    "cpy-notice-pat-exam": TranslatorConfigItems(
        ### A101, A102, A1131 特許査定、拒絶査定、拒絶理由通知書 テキストブロック
        xsl_path=xsl_path("cpy-ntc-pt-e.xsl"),
        namespace="http://www.jpo.go.jp",
        doctype="cpy-notice-pat-exam",
        default_filename="cpy-notice-pat-exam-blocks.json",
    ),
    "cpy-notice-pat-exam-rn": TranslatorConfigItems(
        ### 新形式 A101, A102, A1131 特許査定、拒絶査定、拒絶理由通知書 テキストブロック
        xsl_path=xsl_path("cpy-ntc-pt-e-rn.xsl"),
        namespace="http://www.jpo.go.jp",
        doctype="cpy-notice-pat-exam-rn",
        default_filename="cpy-notice-pat-exam-rn-blocks.json",
    ),
    "cpy-notice-pat-frm": TranslatorConfigItems(
        ### 実案技術評価書の通知
        xsl_path=xsl_path("cpy-ntc-pt-f.xsl"),
        namespace="http://www.jpo.go.jp",
        doctype="cpy-notice-pat-frm",
        default_filename="cpy-notice-pat-frm-blocks.json",
    ),
    "full-text": TranslatorConfigItems(
        ### 全文検索用フィールド
        xsl_path=xsl_path("fields.xsl"),
        namespace="",
        doctype="*",
        default_filename="fields.json",
    ),
}
