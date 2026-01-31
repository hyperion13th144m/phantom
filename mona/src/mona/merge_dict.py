from copy import deepcopy
from typing import Any, Dict, List, Union


# 動作の仕組み：
#
# deepcopyを使用して元の辞書を変更しない
# リスト同士は+演算子で連結
# 辞書同士は再帰的にdeep_mergeを呼び出し
# その他の型や型が一致しない場合は、sourceの値で上書き
def deep_merge(target: Dict[str, Any], source: Dict[str, Any]) -> Dict[str, Any]:
    """
    2つの辞書を深くマージする関数

    Args:
        target: マージ元の辞書
        source: マージする辞書

    Returns:
        マージされた辞書
    """
    result = deepcopy(target)

    for key, source_value in source.items():
        if key in result:
            target_value = result[key]

            # 両方がリストの場合は連結
            if isinstance(source_value, list) and isinstance(target_value, list):
                result[key] = target_value + source_value
            # 両方が辞書の場合は再帰的にマージ
            elif isinstance(source_value, dict) and isinstance(target_value, dict):
                result[key] = deep_merge(target_value, source_value)
            # その他の場合は上書き
            else:
                result[key] = deepcopy(source_value)
        else:
            # キーが存在しない場合は追加
            result[key] = deepcopy(source_value)

    return result


if __name__ == "__main__":
    # 使用例
    dict_a = {
        "root": {
            "docId": "1888432f8sa",
            "key1": ["1", "2"],
            "key2": "hoge",
            "blocks": [{"tag": "hoge"}, {"tag": "hoge2"}],
            "fields": {"f1": "aioefjef", "f2": "iewofejf"},
        }
    }

    dict_b = {
        "root": {
            "key3": ["3", "4"],
            "key4": "fuga",
            "blocks": [{"tag": "hoge3"}],
            "fields": {"f3": "aaaaef", "f4": "isdfsadfejf"},
        }
    }

    # マージ実行
    dict_c = deep_merge(dict_a, dict_b)

    print(dict_c)
