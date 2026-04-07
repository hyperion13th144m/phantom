import asyncio
import hashlib
import hmac
import json
import os
from datetime import UTC, datetime
from threading import Lock
from typing import Any, TypedDict

from fastapi import APIRouter, HTTPException, Query, Request

from navi.mona_client import MonaClient, MonaClientError
from navi.panther_client import PantherClient, PantherClientError
from navi.ui import templates

router = APIRouter(prefix="/orchestration", tags=["orchestration"])

_SUCCESS_STATUSES = {"completed", "complete", "success", "succeeded", "finished", "done"}


class _CrowCompletedPayload(TypedDict, total=False):
    crow_job_id: str
    status: str
    finished_at: str
    panther_request: dict[str, Any]
    skip_panther: bool
    skip_mona: bool


class _PipelineStepResult(TypedDict, total=False):
    triggered: bool
    ok: bool
    response: dict[str, Any] | None
    error: str | None


class _PipelineRecord(TypedDict, total=False):
    crow_job_id: str
    crow_status: str
    received_at: str
    finished_at: str | None
    state: str
    panther: _PipelineStepResult
    mona: _PipelineStepResult


class OrchestrationState:
    def __init__(self):
        self._lock = Lock()
        self._records: dict[str, _PipelineRecord] = {}

    def get(self, crow_job_id: str) -> _PipelineRecord | None:
        with self._lock:
            existing = self._records.get(crow_job_id)
            if existing is None:
                return None
            return json.loads(json.dumps(existing))

    def set_if_absent(self, crow_job_id: str, record: _PipelineRecord) -> bool:
        with self._lock:
            if crow_job_id in self._records:
                return False
            self._records[crow_job_id] = record
            return True

    def update(self, crow_job_id: str, record: _PipelineRecord) -> None:
        with self._lock:
            self._records[crow_job_id] = record

    def list_recent(self, limit: int = 20) -> list[_PipelineRecord]:
        with self._lock:
            values = list(self._records.values())
        values.sort(key=lambda item: item.get("received_at", ""), reverse=True)
        return values[: max(1, min(limit, 100))]


state = OrchestrationState()


def _utc_now_iso() -> str:
    return datetime.now(tz=UTC).isoformat()


def _webhook_secret() -> str:
    return os.getenv("ORCHESTRATION_WEBHOOK_SECRET", "")


def _verify_webhook_signature(raw_body: bytes, signature_header: str | None) -> None:
    secret = _webhook_secret()
    if not secret:
        return

    if not signature_header:
        raise HTTPException(status_code=401, detail="Missing webhook signature")

    if signature_header.startswith("sha256="):
        provided = signature_header.split("=", 1)[1].strip()
    else:
        provided = signature_header.strip()

    expected = hmac.new(secret.encode("utf-8"), raw_body, hashlib.sha256).hexdigest()
    if not hmac.compare_digest(provided, expected):
        raise HTTPException(status_code=401, detail="Invalid webhook signature")


def _validate_payload(data: dict[str, Any]) -> _CrowCompletedPayload:
    crow_job_id = str(data.get("crow_job_id", "")).strip()
    status = str(data.get("status", "")).strip()

    if not crow_job_id:
        raise HTTPException(status_code=400, detail="crow_job_id is required")
    if not status:
        raise HTTPException(status_code=400, detail="status is required")

    payload: _CrowCompletedPayload = {
        "crow_job_id": crow_job_id,
        "status": status,
        "finished_at": str(data.get("finished_at", "")).strip() or None,
        "skip_panther": bool(data.get("skip_panther", False)),
        "skip_mona": bool(data.get("skip_mona", False)),
    }

    panther_request = data.get("panther_request")
    if isinstance(panther_request, dict):
        payload["panther_request"] = panther_request
    return payload


def _is_success_status(status: str) -> bool:
    return status.strip().lower() in _SUCCESS_STATUSES


def _run_panther_step(payload: _CrowCompletedPayload) -> _PipelineStepResult:
    if payload.get("skip_panther"):
        return {"triggered": False, "ok": True, "response": None, "error": None}

    default_request: dict[str, Any] = {
        "id_list": None,
        "chunk_size": 500,
        "max_retries": 5,
        "use_hash_guard": False,
    }
    requested = payload.get("panther_request")
    if isinstance(requested, dict):
        default_request.update(requested)

    client = PantherClient()
    try:
        response = client.start_job(default_request)
    except PantherClientError as exc:
        return {
            "triggered": True,
            "ok": False,
            "response": None,
            "error": str(exc),
        }

    return {
        "triggered": True,
        "ok": True,
        "response": dict(response),
        "error": None,
    }


def _run_mona_step(payload: _CrowCompletedPayload) -> _PipelineStepResult:
    if payload.get("skip_mona"):
        return {"triggered": False, "ok": True, "response": None, "error": None}

    client = MonaClient()
    try:
        response = client.reload_documents()
    except MonaClientError as exc:
        return {
            "triggered": True,
            "ok": False,
            "response": None,
            "error": str(exc),
        }

    return {
        "triggered": True,
        "ok": True,
        "response": dict(response),
        "error": None,
    }


@router.get("/")
def orchestration_admin(
    request: Request,
    job_id: str | None = Query(default=None),
    limit: int = Query(default=20, ge=1, le=100),
):
    items = state.list_recent(limit=limit)

    selected_job_id = (job_id or "").strip() or None
    selected_pipeline = state.get(selected_job_id) if selected_job_id else None
    selected_pipeline_pretty = None
    if selected_pipeline is not None:
        selected_pipeline_pretty = json.dumps(selected_pipeline, ensure_ascii=False, indent=2)

    return templates.TemplateResponse(
        "orchestration/index.html",
        {
            "request": request,
            "items": items,
            "limit": limit,
            "selected_job_id": selected_job_id,
            "selected_pipeline": selected_pipeline,
            "selected_pipeline_pretty": selected_pipeline_pretty,
        },
    )


@router.post("/crow-completed")
async def handle_crow_completed_webhook(request: Request):
    raw_body = await request.body()
    _verify_webhook_signature(raw_body, request.headers.get("X-Webhook-Signature"))

    try:
        data = json.loads(raw_body.decode("utf-8"))
    except json.JSONDecodeError as exc:
        raise HTTPException(status_code=400, detail="invalid JSON payload") from exc

    if not isinstance(data, dict):
        raise HTTPException(status_code=400, detail="payload must be a JSON object")

    payload = _validate_payload(data)
    crow_job_id = payload["crow_job_id"]
    crow_status = payload["status"]

    existing = state.get(crow_job_id)
    if existing is not None:
        return {
            "ok": True,
            "duplicate": True,
            "pipeline": existing,
        }

    record: _PipelineRecord = {
        "crow_job_id": crow_job_id,
        "crow_status": crow_status,
        "received_at": _utc_now_iso(),
        "finished_at": payload.get("finished_at"),
        "state": "accepted",
        "panther": {"triggered": False, "ok": False, "response": None, "error": None},
        "mona": {"triggered": False, "ok": False, "response": None, "error": None},
    }
    inserted = state.set_if_absent(crow_job_id, record)
    if not inserted:
        newest = state.get(crow_job_id)
        return {
            "ok": True,
            "duplicate": True,
            "pipeline": newest,
        }

    if not _is_success_status(crow_status):
        record["state"] = "ignored"
        state.update(crow_job_id, record)
        return {
            "ok": True,
            "duplicate": False,
            "pipeline": record,
            "message": "crow status is not successful, downstream jobs were not triggered",
        }

    record["state"] = "running"
    state.update(crow_job_id, record)

    panther_result, mona_result = await asyncio.gather(
        asyncio.to_thread(_run_panther_step, payload),
        asyncio.to_thread(_run_mona_step, payload),
    )

    record["panther"] = panther_result
    record["mona"] = mona_result
    record["state"] = "completed"
    state.update(crow_job_id, record)

    return {
        "ok": True,
        "duplicate": False,
        "pipeline": record,
    }


@router.get("/pipelines/{crow_job_id}")
def get_pipeline(crow_job_id: str):
    pipeline = state.get(crow_job_id)
    if pipeline is None:
        raise HTTPException(status_code=404, detail="pipeline not found")
    return pipeline


@router.get("/pipelines")
def list_pipelines(limit: int = 20):
    return {"items": state.list_recent(limit=limit)}
