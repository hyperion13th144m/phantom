from __future__ import annotations

import re
import unicodedata

from pydantic import ValidationError

from panther.models.generated.full_text import FullText

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


def rewrite_rejection_reason_article(text: str) -> str:
    reason_pattern = [
        {
            "pattern": r"^第１７条の２第３項$",
            "replacement": "第１７条の２第３項（新規事項）",
        },
        {"pattern": r"^第２９条の２$", "replacement": "第２９条の２（拡大先願）"},
        {"pattern": r"^第２９条第２項$", "replacement": "第２９条第２項（進歩性）"},
        {"pattern": r"^第３７条$", "replacement": "第３７条（単一性）"},
    ]
    for reason in reason_pattern:
        if re.match(reason["pattern"], text):
            return reason["replacement"]
    else:
        return text


def rewrite_name(text: str) -> str:
    """名前中の全角スペースを半角スペースに変換し、前後のスペースを削除する。
    ▲▼を削除する"""
    text = text.replace("\u3000", " ")  # 全角スペースを半角スペースに変換
    text = text.replace("▲", "").replace("▼", "")  # ▲▼を削除
    return text.strip()


# -----------------------------
# FullText を正規化する
# -----------------------------
normalize_functions = {
    "fileReferenceId": zenkaku_to_hankaku_all,
    "applicationNumber": zenkaku_to_hankaku_all,
    "internationalApplicationNumber": zenkaku_to_hankaku_all,
    "registrationNumber": zenkaku_to_hankaku_all,
    "appealReferenceNumber": zenkaku_to_hankaku_all,
    "receiptNumber": zenkaku_to_hankaku_all,
    "rejectionReasonArticle": rewrite_rejection_reason_article,
    "applicants": rewrite_name,
    "inventors": rewrite_name,
    "agents": rewrite_name,
}


def normalize_document(full_text: FullText) -> FullText:
    data = full_text.model_dump()
    for key, value in data.items():
        if key in normalize_functions and isinstance(value, str):
            data[key] = normalize_functions[key](value)
        elif key in normalize_functions and isinstance(value, list):
            data[key] = [
                normalize_functions[key](v) for v in value if isinstance(v, str)
            ]

    return FullText(**data)


if __name__ == "__main__":
    import sys

    # full-text.json
    with open(sys.argv[1], "r", encoding="utf-8") as f:
        full_text = FullText.model_validate_json(f.read())

    try:
        full_text2 = normalize_document(full_text)
        print(full_text2.model_dump_json(indent=2, ensure_ascii=False))
    except ValidationError as e:
        print("Validation error:", e)
        sys.exit(1)
