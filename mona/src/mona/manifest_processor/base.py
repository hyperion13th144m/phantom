"""Base class for manifest processors."""
from abc import ABC, abstractmethod
from pathlib import Path

from libefiling import Manifest


class ManifestProcessor(ABC):
    def __init__(self, manifest_path: Path):
        self.manifest_dir = manifest_path.parent
        with open(manifest_path, "r", encoding="utf-8") as f:
            self.manifest = Manifest.model_validate_json(f.read())

    @abstractmethod
    def translate(self) -> list[dict]:
        pass
