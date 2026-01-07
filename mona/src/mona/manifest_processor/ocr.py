import re

from .base import ManifestProcessor


class OCRProcessor(ManifestProcessor):
    def translate(self) -> list[dict]:
        ocr_results = []
        ocr_files = [image.ocr.path for image in self.manifest.images]
        for ocr_file in ocr_files:
            ocr_path = self.manifest_dir / ocr_file
            with open(ocr_path, "r", encoding="utf-8") as f:
                text = f.read()
            ocr_results.append(re.sub(r"\s+", " ", text).strip())
        return [{"root": {"ocrText": "".join(ocr_results)}}]
 