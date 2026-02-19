import json

from libefiling import Manifest


def metadata(manifest: Manifest, output_path: str) -> None:
    for s in manifest.document.sources:
        if s.extension.upper().endswith((".JWX", "JWS", "JPC", "JPD")):
            task = s.task
            kind = s.kind
            break
    else:
        task = "unknown"
        kind = "unknown"
    data = {
        "docId": manifest.document.doc_id,
        "task": task,
        "kind": kind,
    }
    json.dump(
        data, open(output_path, "w", encoding="utf-8"), ensure_ascii=False, indent=2
    )
