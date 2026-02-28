import re
import unicodedata
from typing import List

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
