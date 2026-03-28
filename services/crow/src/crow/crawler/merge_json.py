import json
import os
from typing import List


def merge_jsons_as_array(json_paths: List[str], output_path: str) -> None:
    merged_data = []
    for path in json_paths:
        if os.path.exists(path) is False:
            continue
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)
            merged_data.append(data)
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(merged_data, f, ensure_ascii=False, indent=2)
