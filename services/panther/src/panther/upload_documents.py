#!/usr/bin/env python3
"""
Bulk upsert documents into Elasticsearch from:
  local: root/<docid>/full-text.json
  mona API: GET /documents/{docid}/json/full-text

- Use _id = docid
- Preserve user-added fields in ES (assignee/tags) by NOT sending them in updates
- Use update API with doc_as_upsert
- Optional: store ingest_hash to skip no-op updates with a painless script
"""

import hashlib
import json
import logging
import time
from collections.abc import Callable, Sequence
from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import TYPE_CHECKING, Literal, TypedDict

from elasticsearch import Elasticsearch, helpers

from panther.models.generated.full_text import FullText
from panther.normalizer import normalize_document

if TYPE_CHECKING:
    from panther.document_source import DocumentSource

logger = logging.getLogger(__name__)

PRESERVE_FIELDS = {"assignees", "tags", "extraNumbers"}
ProgressCallback = Callable[["UploadProgress"], None]
BulkProgressCallback = Callable[[int, int], None]


class UploadCancelledError(Exception):
    """Raised when a running upload has been cancelled."""


class DocumentPayload(TypedDict, total=False):
    docId: str
    ingest_hash: str
    ingested_at: str


class ScriptSpec(TypedDict):
    lang: str
    source: str
    params: dict[str, object]


class BaseBulkAction(TypedDict):
    _op_type: Literal["update"]
    _index: str
    _id: str
    retry_on_conflict: int


class ScriptedBulkAction(BaseBulkAction):
    scripted_upsert: Literal[True]
    script: ScriptSpec
    upsert: DocumentPayload


class DocAsUpsertBulkAction(BaseBulkAction):
    doc_as_upsert: Literal[True]
    doc: DocumentPayload


BulkAction = ScriptedBulkAction | DocAsUpsertBulkAction


@dataclass(frozen=True)
class UploadProgress:
    total: int
    success: int
    failed: int

    @property
    def progress(self) -> float:
        if self.total == 0:
            return 1.0
        return (self.success + self.failed) / self.total


@dataclass(frozen=True)
class UploadResult(UploadProgress):
    source: str
    requested_ids: list[str] | None = None
    missing_ids: list[str] = field(default_factory=list)


BulkErrorInfo = dict[str, object]
BulkErrorItem = dict[str, BulkErrorInfo]


def utc_now_iso() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds")


def stable_hash(obj: dict[str, object]) -> str:
    data = json.dumps(
        obj, ensure_ascii=False, sort_keys=True, separators=(",", ":")
    ).encode("utf-8")
    return hashlib.sha256(data).hexdigest()


def strip_preserve_fields(doc: dict[str, object]) -> dict[str, object]:
    return {k: v for k, v in doc.items() if k not in PRESERVE_FIELDS}


def notify_progress(
    on_progress: ProgressCallback | None,
    total: int,
    success: int,
    failed: int,
) -> None:
    if on_progress is None:
        return
    on_progress(UploadProgress(total=total, success=success, failed=failed))


def build_action(
    index: str,
    full_text: FullText,
    use_hash_guard: bool,
) -> BulkAction:
    normalized = normalize_document(full_text)
    edited = json.loads(normalized.model_dump_json(exclude_none=True))
    if not isinstance(edited, dict):
        raise ValueError("normalized document must be a JSON object")
    doc = strip_preserve_fields(edited)

    docid_value = doc.get("docId")
    if not isinstance(docid_value, str):
        raise ValueError("normalized document is missing string docId")
    ingest_hash = stable_hash(doc)
    now = utc_now_iso()
    stored_doc: DocumentPayload = {
        **doc,
        "ingest_hash": ingest_hash,
        "ingested_at": now,
    }

    if use_hash_guard:
        return {
            "_op_type": "update",
            "_index": index,
            "_id": docid_value,
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
            "upsert": stored_doc,
        }

    return {
        "_op_type": "update",
        "_index": index,
        "_id": docid_value,
        "retry_on_conflict": 3,
        "doc_as_upsert": True,
        "doc": stored_doc,
    }


def execute_upload(
    es: Elasticsearch,
    index: str,
    source: "DocumentSource",
    chunk_size: int = 500,
    max_retries: int = 5,
    use_hash_guard: bool = False,
    should_cancel: Callable[[], bool] | None = None,
    on_progress: ProgressCallback | None = None,
    id_list: Sequence[str] | None = None,
) -> UploadResult:
    """Upload documents to Elasticsearch and return summary details."""
    try:
        requested_ids = [str(doc_id) for doc_id in id_list] if id_list else None
        missing_ids = source.missing_ids(id_list=requested_ids)
        logger.info("Connecting to Elasticsearch: %s", es)
        if not es.ping():
            logger.error("Error: Cannot connect to Elasticsearch")
            notify_progress(on_progress, total=0, success=0, failed=1)
            return UploadResult(
                source=source.source,
                total=0,
                success=0,
                failed=1,
                requested_ids=requested_ids,
                missing_ids=missing_ids,
            )

        logger.info("Connected to Elasticsearch")
        logger.info("Uploading documents from: %s", source.label)
        actions = [
            build_action(index=index, full_text=full_text, use_hash_guard=use_hash_guard)
            for full_text in source.iter_full_texts(
                should_cancel=should_cancel,
                id_list=requested_ids,
            )
        ]
        total = len(actions)
        notify_progress(on_progress, total=total, success=0, failed=0)

        def handle_bulk_progress(success: int, failed: int) -> None:
            notify_progress(on_progress, total=total, success=success, failed=failed)

        success, failed = bulk_upsert_with_retries(
            es,
            actions,
            chunk_size=chunk_size,
            max_retries=max_retries,
            initial_backoff=1.0,
            max_backoff=30.0,
            should_cancel=should_cancel,
            on_progress=handle_bulk_progress,
        )

        return UploadResult(
            source=source.source,
            total=total,
            success=success,
            failed=failed,
            requested_ids=requested_ids,
            missing_ids=missing_ids,
        )
    finally:
        es.close()



def format_upload_result_summary(result: UploadResult) -> str:
    return (
        f"Upload completed: source={result.source} total={result.total} "
        f"success={result.success} failed={result.failed} progress={result.progress:.2f}"
    )


def bulk_upsert_with_retries(
    es: Elasticsearch,
    actions: list[BulkAction],
    chunk_size: int,
    max_retries: int,
    initial_backoff: float,
    max_backoff: float,
    should_cancel: Callable[[], bool] | None = None,
    on_progress: BulkProgressCallback | None = None,
) -> tuple[int, int]:
    """
    Bulk upsert with retry/backoff for transient errors.
    Returns: (success, failed)
    """
    success = 0
    failed = 0

    backoff = initial_backoff
    to_send = list(actions)
    attempt = 0

    while True:
        attempt += 1
        errors_accum: list[BulkErrorItem] = []
        ok_count = 0

        for ok, item in helpers.streaming_bulk(
            es,
            to_send,
            chunk_size=chunk_size,
            raise_on_error=False,
            raise_on_exception=False,
            max_retries=0,
        ):
            if ok:
                ok_count += 1
            else:
                errors_accum.append(item)
            if should_cancel and should_cancel():
                raise UploadCancelledError("Upload was cancelled during bulk request")

        failed_items: list[BulkAction] = []
        permanent_failures = 0
        for err in errors_accum:
            op = next(iter(err.keys()))
            info = err[op]
            status = info.get("status")
            if status not in (408, 409, 429, 500, 502, 503, 504):
                permanent_failures += 1
                logger.error("[FAIL] status=%s item=%s", status, err)

        lookup = {action["_id"]: action for action in to_send}
        for err in errors_accum:
            op = next(iter(err.keys()))
            info = err[op]
            status = info.get("status")
            if status in (408, 409, 429, 500, 502, 503, 504):
                item_id = info.get("_id")
                if isinstance(item_id, str) and item_id in lookup:
                    failed_items.append(lookup[item_id])
                else:
                    permanent_failures += 1
                    logger.error(
                        "[FAIL] could not find original action for _id=%s", item_id
                    )

        success += ok_count
        failed += permanent_failures
        if (ok_count or permanent_failures) and on_progress is not None:
            on_progress(success, failed)

        if not errors_accum or not failed_items:
            return success, failed

        if attempt > max_retries:
            failed += len(failed_items)
            logger.error("[GIVE UP] retries exceeded for %s items", len(failed_items))
            if on_progress is not None:
                on_progress(success, failed)
            return success, failed

        logger.warning(
            "[RETRY] attempt=%s/%s retry_items=%s backoff=%.1fs",
            attempt,
            max_retries,
            len(failed_items),
            backoff,
        )
        time.sleep(backoff)
        backoff = min(max_backoff, backoff * 2)
        to_send = failed_items
