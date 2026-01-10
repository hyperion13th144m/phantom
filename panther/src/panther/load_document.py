"""document.json を読み込む例"""

import json
from pathlib import Path

from panther.types import Document


def load_document(file_path: str | Path) -> Document:
    """
    document.json を読み込んで型付きで返す

    Args:
        file_path: document.json のパス

    Returns:
        Document: 型付きされたドキュメントデータ
    """
    with open(file_path, encoding="utf-8") as f:
        data: Document = json.load(f)
    return data


# 使用例
if __name__ == "__main__":
    doc = load_document("document.json")
    
    # 型推論が効いているので、IDE で補完が効きます
    print(f"Document ID: {doc['docId']}")
    print(f"Document Name: {doc['documentName']}")
    print(f"Application Number: {doc['applicationNumber']}")
    
    # textBlocksRoot の走査
    for root_block in doc["textBlocksRoot"]:
        print(f"Tag: {root_block['tag']}")
        if "jpTag" in root_block:
            print(f"JP Tag: {root_block['jpTag']}")
