import re

from .base import ManifestProcessor


class OCRProcessor(ManifestProcessor):
    def sanitize_for_json(self, text: str) -> str:
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
        return text

    def translate(self) -> list[dict]:
        ocr_results = []
        ocr_files = [image.ocr.path for image in self.manifest.images]
        for ocr_file in ocr_files:
            ocr_path = self.manifest_dir / ocr_file
            with open(ocr_path, "r", encoding="utf-8") as f:
                text = f.read()
            sanitized_text = self.sanitize_for_json(text)
            ocr_results.append(re.sub(r"\s+", " ", sanitized_text).strip())
        return [{"root": {"ocrText": "".join(ocr_results)}}]
