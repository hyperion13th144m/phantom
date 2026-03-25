#!/usr/bin/env python3
"""
Bulk upsert documents into Elasticsearch from:
  data/<docid>/bibliography.json,full-text.json,images-information.json

- Use _id = docid
- Preserve user-added fields in ES (assignee/tags) by NOT sending them in updates
- Use update API with doc_as_upsert
- Optional: store ingest_hash to skip no-op updates with a painless script
"""

import argparse
import hashlib
import json
import logging
import os
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Callable, Dict, Iterable, Iterator, List, Optional, Protocol, Tuple
from urllib.parse import quote, urljoin
from urllib.request import urlopen

from elasticsearch import Elasticsearch, helpers  # pip install elasticsearch
from panther.es_client import create_es_client
from panther.models.generated.bibliographic_items import BibliographicItems
from panther.models.generated.full_text import FullText
from panther.models.generated.images_information import ImagesInformation
from panther.patent_doc_editor import PatentDocEditor

logger = logging.getLogger(__name__)

PRESERVE_FIELDS = {"assignees", "tags", "extraNumbers"}  # user-managed fields in ES


class UploadCancelledError(Exception):
    """Raised when a running upload has been cancelled."""


class UploadResult(Dict[str, int | str]):
    pass


class SupportsAddParser(Protocol):
    def add_parser(self, name: str, **kwargs: Any) -> argparse.ArgumentParser: ...


def add_args(parser: SupportsAddParser) -> None:
    p = parser.add_parser(
        "upload-documents",
        help="Upload documents to Elasticsearch",
    )
    p.add_argument(
        "--data-root",
        default="data",
        help="Root directory containing docid/document.json files (default: data)",
    )
    p.add_argument(
        "--mona-base-url",
        default=os.getenv("MONA_BASE_URL"),
        help="Base URL of mona API server, e.g. http://localhost:8000",
    )
    p.add_argument(
        "--pipeline",
        default=os.getenv("ES_PIPELINE"),
        help="Ingest pipeline name (default: $ES_PIPELINE)",
    )
    p.add_argument(
        "--chunk-size",
        type=int,
        default=500,
        help="Bulk chunk size (default: 500)",
    )
    p.add_argument(
        "--max-retries",
        type=int,
        default=5,
        help="Max retry attempts for transient failures (default: 5)",
    )
    p.add_argument(
        "--use-hash-guard",
        action="store_true",
        help="Skip updates if ingest_hash unchanged",
    )
    p.add_argument(
        "--refresh",
        action="store_true",
        help="Refresh index after bulk (slower but makes documents immediately searchable)",
    )
    p.set_defaults(func=main)


def main(args: argparse.Namespace) -> int:
    """Upload documents to Elasticsearch."""
    try:
        result = execute_upload(args)
        logger.info(
            f"\n[DONE] source={result['source']} Total: {result['total']}, Success: {result['success']}, Failed: {result['failed']}"
        )
        return 0 if result["failed"] == 0 else 1
    except UploadCancelledError:
        logger.warning("Upload cancelled")
        return 1
    except Exception as e:
        logger.error(f"Error: {e}")
        return 1


def execute_upload(
    args: argparse.Namespace,
    should_cancel: Optional[Callable[[], bool]] = None,
) -> UploadResult:
    """Upload documents to Elasticsearch and return summary details."""
    data_root = Path(args.data_root)
    use_api = bool(args.mona_base_url)
    if not use_api and not data_root.exists():
        raise FileNotFoundError(f"Data root not found: {data_root}")

    # Connect to Elasticsearch
    logger.info(f"Connecting to Elasticsearch: {args.es}")
    es = create_es_client(args)
    try:
        # Check connection
        if not es.ping():
            logger.error("Error: Cannot connect to Elasticsearch")
            return 1

        logger.info("✓ Connected to Elasticsearch")
        source_label = args.mona_base_url if use_api else str(data_root)
        logger.info(f"Uploading documents from: {source_label}")

        if use_api:
            actions = list(
                build_actions_from_mona_api(
                    index=args.index,
                    mona_base_url=args.mona_base_url,
                    pipeline=args.pipeline,
                    use_hash_guard=args.use_hash_guard,
                    should_cancel=should_cancel,
                )
            )
            source = "mona-api"
        else:
            actions = list(
                build_actions_from_local(
                    index=args.index,
                    data_root=data_root,
                    pipeline=args.pipeline,
                    use_hash_guard=args.use_hash_guard,
                    should_cancel=should_cancel,
                )
            )
            source = "local"

        # Bulk upsert with retries
        success, failed = bulk_upsert_with_retries(
            es,
            actions,
            chunk_size=args.chunk_size,
            max_retries=args.max_retries,
            initial_backoff=1.0,
            max_backoff=30.0,
            should_cancel=should_cancel,
        )

        if args.refresh:
            logger.info("Refreshing index...")
            es.indices.refresh(index=args.index)

        return {
            "source": source,
            "total": len(actions),
            "success": success,
            "failed": failed,
        }
    finally:
        es.close()


def utc_now_iso() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds")


def stable_hash(obj: Dict) -> str:
    """
    Create a stable hash of a dict (order-independent).
    """
    data = json.dumps(
        obj, ensure_ascii=False, sort_keys=True, separators=(",", ":")
    ).encode("utf-8")
    return hashlib.sha256(data).hexdigest()


def strip_preserve_fields(doc: Dict) -> Dict:
    """
    Remove user-managed fields so we never overwrite them by accident.
    """
    if not isinstance(doc, dict):
        raise ValueError("document.json must be a JSON object")
    return {k: v for k, v in doc.items() if k not in PRESERVE_FIELDS}


def iter_documents(root: Path) -> Iterator[Path]:
    """
    Yield json_path from root/data/<docid>, bibliography.json exists in the path.
    """
    # Expect structure: root/docid/bibliography.json, where root is data/
    # We'll find all document-sections.json under data/**/document-sections.json
    for p in root.rglob("bibliography.json"):
        yield p.parent


def load_document_json(
    path: Path,
) -> tuple[BibliographicItems, FullText, List[ImagesInformation]]:
    bib = json.loads((path / "bibliography.json").read_text(encoding="utf-8"))
    full_text = json.loads((path / "full-text.json").read_text(encoding="utf-8"))
    images_info = json.loads(
        (path / "images-information.json").read_text(encoding="utf-8")
    )

    # pydantic v2: model_validate
    return (
        BibliographicItems(**bib),
        FullText(**full_text),
        [ImagesInformation(**img) for img in images_info],
    )


def build_action(
    index: str,
    jsons: tuple[BibliographicItems, FullText, List[ImagesInformation]],
    pipeline: Optional[str],
    use_hash_guard: bool,
) -> Dict:
    _doc = PatentDocEditor(*jsons).to_es_model()
    edited = _doc.model_dump(exclude_none=True)
    doc = strip_preserve_fields(edited)

    docid = doc["docId"]
    ingest_hash = stable_hash(doc)
    now = utc_now_iso()

    if use_hash_guard:
        action = {
            "_op_type": "update",
            "_index": index,
            "_id": docid,
            "retry_on_conflict": 3,
            "scripted_upsert": True,
            "script": {
                "lang": "painless",
                "source": """
                    if (ctx._source.ingest_hash != params.ingest_hash) {
                        // merge doc (does not delete unspecified fields)
                        for (entry in params.doc.entrySet()) {
                            ctx._source[entry.getKey()] = entry.getValue();
                        }
                        ctx._source.ingest_hash = params.ingest_hash;
                        ctx._source.ingested_at = params.now;
                    }
                """,
                "params": {"doc": doc, "ingest_hash": ingest_hash, "now": now},
            },
            "upsert": {
                **doc,
                "ingest_hash": ingest_hash,
                "ingested_at": now,
            },
        }
    else:
        action = {
            "_op_type": "update",
            "_index": index,
            "_id": docid,
            "retry_on_conflict": 3,
            "doc_as_upsert": True,
            "doc": {
                **doc,
                "ingest_hash": ingest_hash,
                "ingested_at": now,
            },
        }

    if pipeline:
        action["pipeline"] = pipeline

    return action


def _load_json_url(base_url: str, endpoint: str) -> Any:
    url = urljoin(base_url.rstrip("/") + "/", endpoint.lstrip("/"))
    with urlopen(url) as response:
        return json.loads(response.read().decode("utf-8"))


def load_document_json_from_mona(
    mona_base_url: str, doc_id: str
) -> tuple[BibliographicItems, FullText, List[ImagesInformation]]:
    encoded_doc_id = quote(doc_id, safe="")
    bib = _load_json_url(mona_base_url, f"/{encoded_doc_id}/json/bibliographic-items")
    full_text = _load_json_url(mona_base_url, f"/{encoded_doc_id}/json/full-text")
    images_info = _load_json_url(
        mona_base_url, f"/{encoded_doc_id}/json/images-information"
    )

    images_list = images_info if isinstance(images_info, list) else [images_info]
    return (
        BibliographicItems(**bib),
        FullText(**full_text),
        [ImagesInformation(**img) for img in images_list],
    )


def build_actions_from_local(
    index: str,
    data_root: Path,
    pipeline: Optional[str],
    use_hash_guard: bool,
    should_cancel: Optional[Callable[[], bool]] = None,
) -> Iterable[Dict]:
    """Generate bulk update actions from local files."""
    for path in iter_documents(data_root):
        if should_cancel and should_cancel():
            raise UploadCancelledError("Upload was cancelled before completion")
        try:
            jsons = load_document_json(path)
            yield build_action(index, jsons, pipeline, use_hash_guard)
        except UploadCancelledError:
            raise
        except Exception as e:
            logger.error(f"[ERROR] {path}: {e}")
            continue


def build_actions_from_mona_api(
    index: str,
    mona_base_url: str,
    pipeline: Optional[str],
    use_hash_guard: bool,
    should_cancel: Optional[Callable[[], bool]] = None,
) -> Iterable[Dict]:
    """Generate bulk update actions from mona REST API."""
    id_list_payload = _load_json_url(mona_base_url, "/idList")
    doc_ids = json.loads(id_list_payload) if isinstance(id_list_payload, str) else id_list_payload
    if not isinstance(doc_ids, list):
        raise ValueError("mona /idList response must be list[str]")

    for doc_id in doc_ids:
        if should_cancel and should_cancel():
            raise UploadCancelledError("Upload was cancelled before completion")
        try:
            jsons = load_document_json_from_mona(mona_base_url, str(doc_id))
            yield build_action(index, jsons, pipeline, use_hash_guard)

        except Exception as e:
            logger.error(f"[ERROR] doc_id={doc_id}: {e}")
            continue


def bulk_upsert_with_retries(
    es: Elasticsearch,
    actions: Iterable[Dict],
    chunk_size: int,
    max_retries: int,
    initial_backoff: float,
    max_backoff: float,
    should_cancel: Optional[Callable[[], bool]] = None,
) -> Tuple[int, int]:
    """
    Bulk upsert with retry/backoff for transient errors.
    Returns: (success, failed)
    """
    success = 0
    failed = 0

    # helpers.bulk yields a tuple (success_count, errors) if raise_on_error=False.
    # We'll implement simple retry around streaming_bulk for better control.

    backoff = initial_backoff
    to_send = list(
        actions
    )  # materialize once for retry simplicity (OK for moderate size)
    attempt = 0

    while True:
        attempt += 1
        errors_accum: List[Dict] = []
        ok_count = 0

        for ok, item in helpers.streaming_bulk(
            es,
            to_send,
            chunk_size=chunk_size,
            raise_on_error=False,
            raise_on_exception=False,
            max_retries=0,  # we handle retries ourselves
        ):
            if ok:
                ok_count += 1
            else:
                errors_accum.append(item)
            if should_cancel and should_cancel():
                raise UploadCancelledError("Upload was cancelled during bulk request")

        if not errors_accum:
            success += ok_count
            return success, failed

        # If we reach here, some items failed.
        # Retry only the failed items.
        failed_items: List[Dict] = []
        for err in errors_accum:
            # err structure: {'update': {'_index':..., '_id':..., 'status':..., 'error':...}}
            op = next(iter(err.keys()))
            info = err[op]
            status = info.get("status")
            # Retry on 429/503/502/504 etc.
            if status in (408, 409, 429, 500, 502, 503, 504):
                # Rebuild original action from the error info:
                # helpers doesn't include original body; so we must keep the original actions list.
                # We'll match by _id.
                _id = info.get("_id")
                # Find the action by _id (O(n)); for large sets use a dict.
                # We'll build a dict once for efficiency.
                pass
            else:
                failed += 1
                logger.error(f"[FAIL] status={status} item={err}")

        # Build lookup dict once, then retry set
        lookup = {a["_id"]: a for a in to_send if "_id" in a}
        for err in errors_accum:
            op = next(iter(err.keys()))
            info = err[op]
            status = info.get("status")
            if status in (408, 409, 429, 500, 502, 503, 504):
                _id = info.get("_id")
                act = lookup.get(_id)
                if act:
                    failed_items.append(act)
                else:
                    failed += 1
                    logger.error(f"[FAIL] could not find original action for _id={_id}")

        if not failed_items:
            success += ok_count
            return success, failed

        if attempt > max_retries:
            failed += len(failed_items)
            logger.error(f"[GIVE UP] retries exceeded for {len(failed_items)} items")
            success += ok_count
            return success, failed

        logger.warning(
            f"[RETRY] attempt={attempt}/{max_retries} retry_items={len(failed_items)} backoff={backoff:.1f}s"
        )
        time.sleep(backoff)
        backoff = min(max_backoff, backoff * 2)
        to_send = failed_items
