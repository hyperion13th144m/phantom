import re
import unicodedata
from typing import List

from libefiling.image.params import ImageConvertParam

SCHEMA_VER = "2.0"

TARGET_DOCUMENT_CODES = [
    "A101",
    "A102",
    "A1131",
    "A1191",
    "A1192",
    "A130",
    "A1523",
    "A163",
    "A1631",  # 翻訳文提出書
    "A1632",  # 国内書面
    # "A1633", # 図面の提出書（実案）は対象外(データないので確認できない)
    "A1634",  # 国際出願翻訳文提出書
    # "A1635", # 国際出願翻訳文提出書（職権）は対象外(データないので確認できない)
    "A153",
    "A159",
    "A1781",
    "A1871",
    "A1872",
    # 実用新案
    "A263",  # 実用新案登録願
    "A2523",  # 手続補正書
    "A2242623",  # 実用新案技術評価の通知
]

# 全角記号と半角記号の対応表
ZENKAKU_TO_HANKAKU_MAP = {
    "\u2212": "-",  # 全角マイナス記号 → 半角マイナス
    "\uff0d": "-",  # 全角ハイフンマイナス → 半角マイナス
    "\u2015": "-",  # 横線（ダッシュ） → 半角マイナス
    "\u2010": "-",  # ハイフン → 半角マイナス
    "\u30fc": "-",  # 長音記号 → 半角マイナス（用途による）
}


def zenkaku_to_hankaku_all(text: str) -> str:
    """
    全角英数字・記号を半角に変換。
    U+2212（全角マイナス）なども正規表現で一括変換。
    """
    # まずNFKC正規化で全角英数字・記号を半角化
    text = unicodedata.normalize("NFKC", text)

    # 全角記号を半角に置換
    pattern = re.compile("|".join(map(re.escape, ZENKAKU_TO_HANKAKU_MAP.keys())))
    text = pattern.sub(lambda m: ZENKAKU_TO_HANKAKU_MAP[m.group()], text)

    return text


def postprocess_application_body(path: List[str], key: str, value: str) -> None:
    if key in ["representative", "is-last-sentence", "is-independent"]:
        return key, value.lower() == "true"
    if key in ["width", "height"]:
        if value.isdigit():
            return key, int(value)
    if len(path) > 0 and path[0][0] == "root" and key in ["images"]:
        if value is None:
            return key, []
    if key == "file-reference-id" and value is not None:
        # 発送系書類は整理番号が全角文字なので半角化
        return key, zenkaku_to_hankaku_all(value).strip()
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
