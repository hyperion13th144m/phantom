import json
import os
from typing import List


def merge_json(json_paths: List[str], output_path: str) -> None:
    merged_data = {}
    for path in json_paths:
        if os.path.exists(path) is False:
            continue
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)
            merged_data = {**merged_data, **data}
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(merged_data, f, ensure_ascii=False, indent=2)


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


def merge_image_info(
    image_info_path: str, image_desc_path: str, ocr_path: str, output_path: str
) -> None:
    if os.path.exists(image_info_path) is False:
        return

    with open(image_info_path, "r", encoding="utf-8") as f:
        image_info_data = json.load(f)

    if os.path.exists(image_desc_path):
        with open(image_desc_path, "r", encoding="utf-8") as f:
            image_desc_data = json.load(f)
    else:
        image_desc_data = []

    if os.path.exists(ocr_path):
        with open(ocr_path, "r", encoding="utf-8") as f:
            ocr_data = json.load(f)
    else:
        ocr_data = []

    merged_data = []
    for info in image_info_data:
        fn = info.get("filename")
        desc = next(
            (d for d in image_desc_data if d.get("file") == fn),
            {},
        )
        ocr = next(
            (o for o in ocr_data if o.get("file") == fn),
            {},
        )
        if "file" in desc:
            del desc["file"]
        if "file" in ocr:
            del ocr["file"]
        merged_data.append({**info, **desc, **ocr})
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(merged_data, f, ensure_ascii=False, indent=2)
