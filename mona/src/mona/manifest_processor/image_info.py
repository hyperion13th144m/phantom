import json
import re
from pathlib import Path

from libefiling import Manifest, generate_sha256, parse_archive


def image_info(manifest: Manifest, output_path: str) -> None:
    image_results = []

    for image in manifest.images:
        # Pydanticモデルを辞書に変換
        image_dict = image.model_dump()

        # ocrキーを削除
        if "ocr" in image_dict:
            del image_dict["ocr"]

        image_results.append(image_dict)

    # 結果をJSONファイルに保存
    json.dump(
        image_results,
        open(output_path, "w", encoding="utf-8"),
        ensure_ascii=False,
        indent=2,
    )
