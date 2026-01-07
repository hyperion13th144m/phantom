from ..config import SCHEMA_VER
from .base import ManifestProcessor


class MetadataProcessor(ManifestProcessor):
    def translate(self) -> list[dict]:
        data = {
            "root": {
                "docId": self.manifest.document.doc_id,
                "archive": self.manifest.document.source.archive_filename,
                "procedure": self.manifest.document.procedure_source.procedure_filename,
                "schemaVer": SCHEMA_VER,
                "ext": self.manifest.document.source.extension,
                "kind": self.manifest.document.source.kind,
                "task": self.manifest.document.source.task,
            }
        }
        return [data]
