#!/usr/bin/env python3
"""
Bulk upsert documents into Elasticsearch from:
  data/<docid>/document.json

- Use _id = docid
- Preserve user-added fields in ES (assignee/tags) by NOT sending them in updates
- Use update API with doc_as_upsert
- Optional: store ingest_hash to skip no-op updates with a painless script
"""

import hashlib
import json
import sys
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, Iterable, Iterator, List, Optional, Tuple

from elasticsearch import Elasticsearch, helpers  # pip install elasticsearch
from panther.es_client import create_es_client
from panther.ip_document import load_ip_document

PRESERVE_FIELDS = {"assignees", "tags"}  # user-managed fields in ES


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
    Yield json_path from root/data/<docid>/document.json
    """
    # Expect structure: root/docid/document.json, where root is data/
    # We'll find all document-sections.json under data/**/document-sections.json
    for p in root.rglob("document.json"):
        yield p


def build_actions(
    index: str,
    data_root: Path,
    pipeline: Optional[str],
    refresh: bool,
    use_hash_guard: bool,
) -> Iterable[Dict]:
    """
    Generate bulk update actions.
    """
    for path in iter_documents(data_root):
        try:
            raw = load_ip_document(path)
            doc = strip_preserve_fields(raw)

            # Put docid inside source too (optional but handy)
            docid = doc["docId"]

            ingest_hash = stable_hash(doc)
            now = utc_now_iso()

            if use_hash_guard:
                # Only update when ingest_hash differs; otherwise do nothing.
                # Still upsert if missing.
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
                # Simple partial update + upsert.
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

            # `refresh` is controlled outside bulk (safer). Kept here for compatibility if needed.
            # helpers.bulk doesn't accept per-action refresh; ignore.

            yield action

        except Exception as e:
            print(f"[ERROR] {path}: {e}", file=sys.stderr)
            continue


def bulk_upsert_with_retries(
    es: Elasticsearch,
    actions: Iterable[Dict],
    chunk_size: int,
    max_retries: int,
    initial_backoff: float,
    max_backoff: float,
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
                print(f"[FAIL] status={status} item={err}", file=sys.stderr)

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
                    print(
                        f"[FAIL] could not find original action for _id={_id}",
                        file=sys.stderr,
                    )

        if not failed_items:
            success += ok_count
            return success, failed

        if attempt > max_retries:
            failed += len(failed_items)
            print(
                f"[GIVE UP] retries exceeded for {len(failed_items)} items",
                file=sys.stderr,
            )
            success += ok_count
            return success, failed

        print(
            f"[RETRY] attempt={attempt}/{max_retries} retry_items={len(failed_items)} backoff={backoff:.1f}s",
            file=sys.stderr,
        )
        time.sleep(backoff)
        backoff = min(max_backoff, backoff * 2)
        to_send = failed_items


def cmd_upload(args) -> int:
    """Upload documents to Elasticsearch."""
    data_root = Path(args.data_root)
    if not data_root.exists():
        print(f"Error: Data root not found: {data_root}", file=sys.stderr)
        return 1

    # Connect to Elasticsearch
    print(f"Connecting to Elasticsearch: {args.es}")
    try:
        es = create_es_client(args)

        # Check connection
        if not es.ping():
            print("Error: Cannot connect to Elasticsearch", file=sys.stderr)
            return 1

        print("✓ Connected to Elasticsearch")
        print(f"Uploading documents from: {data_root}")

        # Build actions
        actions = build_actions(
            index=args.index,
            data_root=data_root,
            pipeline=args.pipeline,
            refresh=args.refresh,
            use_hash_guard=args.use_hash_guard,
        )

        # Bulk upsert with retries
        success, failed = bulk_upsert_with_retries(
            es,
            actions,
            chunk_size=args.chunk_size,
            max_retries=args.max_retries,
            initial_backoff=1.0,
            max_backoff=30.0,
        )

        if args.refresh:
            print("Refreshing index...")
            es.indices.refresh(index=args.index)

        print(f"\n[DONE] Success: {success}, Failed: {failed}")
        return 0 if failed == 0 else 1

    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        return 1
    finally:
        if "es" in locals():
            es.close()
