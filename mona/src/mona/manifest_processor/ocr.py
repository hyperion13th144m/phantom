import json
import re
from pathlib import Path

from libefiling import Manifest


def ocr(manifest: Manifest, output_path: str) -> None:
    ocr_results = []
    for i in manifest.images:
        fn = i.filename
        if i.ocr:
            ocr_text_path = (
                Path(manifest.paths.root) / manifest.paths.ocr_dir / i.ocr.filename
            )
            text = load_ocr_text(ocr_text_path)
            ocr_results.append(
                {
                    "file": fn,
                    "text": text,
                }
            )
        else:
            continue
    json.dump(
        ocr_results,
        open(output_path, "w", encoding="utf-8"),
        ensure_ascii=False,
        indent=2,
    )


def load_ocr_text(ocr_path: Path) -> str:
    with ocr_path.open("r", encoding="utf-8") as f:
        text = f.read()
        return sanitize(text)


def sanitize(text: str) -> str:
    """
    JSONファイルに安全に保存できるよう、問題のある文字を削除します。

    Args:
        text: 処理対象のテキスト

    Returns:
        サニタイズされたテキスト
    """
    # シングルクォート、ダブルクォート、バックスラッシュ、改行コードを削除
    text = text.replace("'", "")
    text = text.replace('"', "")
    text = text.replace("\\", "")
    text = text.replace("\n", "")
    text = text.replace("\r", "")
    text = re.sub(r"\s+", " ", text)
    text = text.strip()
    return text
