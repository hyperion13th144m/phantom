from ..config import SCHEMA_VER
from .base import ManifestProcessor


class MetadataProcessor(ManifestProcessor):
    def translate(self) -> list[dict]:
        data = {
            "root": {
                "docId": self.manifest.document.doc_id,
                "sources": [s.model_dump() for s in self.manifest.document.sources],
                "schemaVer": SCHEMA_VER,
            }
        }
        return [data]
