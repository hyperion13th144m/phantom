from typing import Any, Callable
from zoneinfo import ZoneInfo
from datetime import datetime
import json


def load_ip_document(file_path: Path) -> dict[str, Any]:
    """IP Document JSONファイルを読み込む"""

    with open(file_path, "r", encoding="utf-8") as f:
        data = json.load(f)
    converted_data = convert_dict(data)
    return converted_data


def convert_dict(src_dict: dict) -> dict[str, Any]:
    """Document を アップロード用のjsonのための辞書に変換する"""
    ex_keys = [
        "archive",
        "procedure",
        "schemaVer",
    ]

    textBlocks = src_dict["textBlocksRoot"]
    dst_dict: dict[str, Any] = exclude_keys(src_dict, *ex_keys)

    # 願書系
    ### 日付文字列を epoch mili-seconds の文字列に変換する
    if "submissionDate" in dst_dict and "submissionTime" in dst_dict:
        date_str = dst_dict["submissionDate"]
        time_str = dst_dict["submissionTime"]
        dt = datetime.strptime(f"{date_str} {time_str} JST", "%Y%m%d %H%M%S %Z")
        dt_jst = dt.replace(tzinfo=ZoneInfo("Asia/Tokyo"))
        epoch_millis = int(dt_jst.timestamp() * 1000)
        dst_dict["submissionDate"] = str(epoch_millis)
        del dst_dict["submissionTime"]

    ### 出願人、発明者、代理人、特記事項
    dst_dict["inventors"] = get_text_list(textBlocks, ["jp:inventor", "jp:name"], None)
    dst_dict["applicants"] = get_text_list(
        textBlocks, ["jp:applicant", "jp:name"], None
    )
    dst_dict["agents"] = get_text_list(textBlocks, ["jp:agent", "jp:name"], None)
    dst_dict["specialMentionMatterArticle"] = get_text_list(
        textBlocks, ["jp:special-mention-matter-article"], None
    )

    # 明細書の項目
    dst_dict["inventionTitle"] = get_text(textBlocks, ["inventionTitle"], None)
    for key in [
        "technicalField",
        "backgroundArt",
        "techProblem",
        "techSolution",
        "advantageousEffects",
        "industrialApplicability",
        "referenceToDepositedBiologicalMaterial",
        "lawOfIndustrialRegenerate",
    ]:
        dst_dict[key] = get_text(
            textBlocks,
            [key, "paragraph"],
        )
    ### 実施形態
    dst_dict["descriptionOfEmbodiments"] = (
        get_text(textBlocks, ["descriptionOfEmbodiments", "paragraph"])
        or get_text(textBlocks, ["bestMode", "paragraph"])
        or ""
    )

    # 請求の範囲
    claims = filter_blocks(textBlocks, ["claims", "claim"])
    i_claims = list(filter(lambda block: block["isIndependent"] == True, claims))
    d_claims = list(filter(lambda block: block["isIndependent"] == False, claims))
    dst_dict["independentClaims"] = get_text(i_claims, ["claimText"])
    dst_dict["dependentClaims"] = get_text(d_claims, ["claimText"])

    # 要約書
    dst_dict["abstract"] = get_text(textBlocks, ["abstract"], None)

    # テキストブロックを削除
    if "textBlocksRoot" in dst_dict:
        del dst_dict["textBlocksRoot"]
    return dst_dict


def get_text(
    blocks: list[dict[str, Any]],
    filter_tags: list[str],
    flatten_key: str | None = "blocks",
    map_func: Callable[[dict[str, Any]], str] = lambda block: block.get("text", ""),
) -> str:
    """指定したタグのテキストを連結して返す
    Args:
        blocks (list[dict[str, Any]]): document.json のdictの textBlocksRoot 又はその要素
        filter_tags (list[str]): 抽出したいtagのリスト。for tag in tags: recursively filter by tag
        flatten_key (str, optional): filter_tags で得られた要素をフラットにするためのキー。Defaults to "blocks". None の場合はフラット化しない.
        map_func (_type_, optional): filter, flatten された要素リストを変換するための関数. Defaults to lambdablock:block.get("text", "").

    Returns:
        str: 得られた要素リストのテキストを連結した文字列
    """
    texts = get_text_list(blocks, filter_tags, flatten_key, map_func)
    return "".join(texts)


def get_text_list(
    blocks: list[dict[str, Any]],
    filter_tags: list[str],
    flatten_key: str | None = "blocks",
    map_func: Callable[[dict[str, Any]], str] = lambda block: block.get("text", ""),
) -> list[str]:
    """指定したタグのリストを返す
    Args:
        same as get_text

    Returns:
        str: 得られた要素リスト
    """
    filtered_blocks = filter_blocks(blocks, filter_tags)
    if flatten_key:
        filtered_blocks = flatten_blocks(filtered_blocks, flatten_key)
    texts = [map_func(block) for block in filtered_blocks]
    # 空文字列を除外
    return [text for text in texts if text]


def flatten_blocks(
    blocks: list[dict[str, Any]], flatten_key: str
) -> list[dict[str, Any]]:
    """ネストされた blocks をフラットなリストに変換する. 一階層のみ"""
    flat_list: list[dict[str, Any]] = []

    for block in blocks:
        if flatten_key in block:
            for sub_block in block[flatten_key]:
                flat_list.append(sub_block)

    return flat_list


def filter_blocks(
    blocks: list[dict[str, Any]], tags: list[str]
) -> list[dict[str, Any]]:
    filtered_blocks = blocks
    for tag in tags:
        filtered_blocks = get_blocks_by_tag(filtered_blocks, tag)
    return filtered_blocks


def exclude_keys(src_dict: dict[str, Any], *keys: str) -> dict[str, Any]:
    """
    指定した複数のキーを除外して、新しい辞書を返す

    Args:
        src_dict: 元の辞書
        *keys: 除外するキーのリスト

    Returns:
        dict: 指定したキーが除外された新しい辞書

    Example:
        >>> new_dict = exclude_keys(src_dict, "ocrText", "images")
    """
    return {k: v for k, v in src_dict.items() if k not in keys}


def get_blocks_by_tag(blocks: list[dict[str, Any]], tag: str) -> list[dict[str, Any]]:
    """blocks を再帰的に走査して、指定された tag の block を返す。

    Args:
        blocks: 探索対象のブロックリスト
        tag: 検索するタグ名

    Returns:
        指定されたタグを持つブロックのリスト
    """
    found_blocks: list[dict[str, Any]] = []

    def _extract_blocks_by_tag(blocks_to_search: list[dict[str, Any]]):
        for block in blocks_to_search:
            if block.get("tag") == tag:
                found_blocks.append(block)
            # 再帰的に探索
            if "blocks" in block:
                _extract_blocks_by_tag(block["blocks"])

    _extract_blocks_by_tag(blocks)
    return found_blocks


if __name__ == "__main__":
    import json
    from pathlib import Path

    with open(Path("document.json"), encoding="utf-8") as f:
        data = json.load(f)

    # キーを除外して新しい辞書を作成
    new_dict1 = convert_dict(data)

    with open(Path("document-out.json"), "w", encoding="utf-8") as f:
        json.dump(new_dict1, f, ensure_ascii=False, indent=2)
