import logging
import os
import sys
import threading
import uuid
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Literal

from elasticsearch import Elasticsearch
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

from panther.document_source import DocumentSource, create_document_source
from panther.es_client import create_es_client
from panther.logger import setup_logging
from panther.upload_documents import (
    UploadCancelledError,
    UploadProgress,
    UploadResult,
    execute_upload,
    format_upload_result_summary,
)


class JobRequest(BaseModel):
    id_list: list[str] | None = None
    chunk_size: int = 500
    max_retries: int = 5
    use_hash_guard: bool = False


class JobStatus(BaseModel):
    job_id: str
    status: Literal["running", "completed", "failed", "cancelled"]
    started_at: str
    updated_at: str
    requested_ids: list[str] | None = None
    missing_ids: list[str] = []
    finished_at: str | None = None
    total: int = 0
    success: int = 0
    failed: int = 0
    progress: float = 0.0
    source: str | None = None
    error: str | None = None

    @classmethod
    def from_upload_result(
        cls,
        job_id: str,
        started_at: str,
        finished_at: str,
        result: UploadResult,
    ) -> "JobStatus":
        return cls(
            job_id=job_id,
            status="completed",
            started_at=started_at,
            updated_at=finished_at,
            requested_ids=result.requested_ids,
            missing_ids=result.missing_ids,
            finished_at=finished_at,
            total=result.total,
            success=result.success,
            failed=result.failed,
            progress=result.progress,
            source=result.source,
        )


def utc_now_iso() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds")


class JobManager:
    def __init__(
        self,
        es: Elasticsearch,
        index: str,
        source: DocumentSource,
    ):
        self._lock = threading.Lock()
        self._jobs: dict[str, JobStatus] = {}
        self._cancel_events: dict[str, threading.Event] = {}
        self._running_job_id: str | None = None
        self._es = es
        self._index = index
        self._source = source

    def start_job(self, request: JobRequest) -> JobStatus:
        estimated_total = self._estimate_total(request.id_list)
        missing_ids = self._source.missing_ids(request.id_list)
        now = utc_now_iso()

        with self._lock:
            if self._running_job_id:
                raise HTTPException(
                    status_code=409, detail="Another job is already running"
                )

            if not self._index:
                raise HTTPException(status_code=400, detail="index is required")

            job_id = str(uuid.uuid4())
            status = JobStatus(
                job_id=job_id,
                status="running",
                started_at=now,
                updated_at=now,
                requested_ids=request.id_list,
                missing_ids=missing_ids,
                total=estimated_total,
                progress=0.0,
                source=self._source.source,
            )
            self._jobs[job_id] = status
            cancel_event = threading.Event()
            self._cancel_events[job_id] = cancel_event
            self._running_job_id = job_id

        worker = threading.Thread(
            target=self._run_job,
            args=(job_id, request, cancel_event),
            daemon=True,
        )
        worker.start()
        return status

    def _estimate_total(self, id_list: list[str] | None = None) -> int:
        try:
            return self._source.doc_count(id_list=id_list)
        except Exception as exc:
            logger.warning("Failed to estimate document count: %s", exc)
            return 0

    def _update_progress(self, job_id: str, progress: UploadProgress) -> None:
        with self._lock:
            current = self._jobs.get(job_id)
            if current is None or current.status != "running":
                return
            self._jobs[job_id] = current.model_copy(
                update={
                    "updated_at": utc_now_iso(),
                    "total": progress.total,
                    "success": progress.success,
                    "failed": progress.failed,
                    "progress": progress.progress,
                    "source": self._source.source,
                }
            )

    def _run_job(
        self, job_id: str, request: JobRequest, cancel_event: threading.Event
    ) -> None:
        try:
            result = execute_upload(
                es=self._es,
                index=self._index,
                source=self._source,
                chunk_size=request.chunk_size,
                max_retries=request.max_retries,
                use_hash_guard=request.use_hash_guard,
                should_cancel=cancel_event.is_set,
                on_progress=lambda progress: self._update_progress(job_id, progress),
                id_list=request.id_list,
            )
            new_status = JobStatus.from_upload_result(
                job_id=job_id,
                started_at=self._jobs[job_id].started_at,
                finished_at=utc_now_iso(),
                result=result,
            )
            self._update_job(job_id, new_status)
            logger.info(
                "job completed: %s %s",
                job_id,
                format_upload_result_summary(result),
            )
        except UploadCancelledError:
            now = utc_now_iso()
            cancelled = self._jobs[job_id].model_copy(
                update={
                    "status": "cancelled",
                    "updated_at": now,
                    "finished_at": now,
                }
            )
            self._update_job(job_id, cancelled)
        except Exception as exc:
            now = utc_now_iso()
            failed = self._jobs[job_id].model_copy(
                update={
                    "status": "failed",
                    "updated_at": now,
                    "finished_at": now,
                    "error": str(exc),
                }
            )
            self._update_job(job_id, failed)
            logger.exception("job failed: %s", job_id)
        finally:
            with self._lock:
                if self._running_job_id == job_id:
                    self._running_job_id = None

    def _update_job(self, job_id: str, status: JobStatus) -> None:
        with self._lock:
            self._jobs[job_id] = status

    def get_current(self) -> dict[str, Any]:
        with self._lock:
            running_job = (
                self._jobs.get(self._running_job_id) if self._running_job_id else None
            )
            latest = None
            if self._jobs:
                latest = list(self._jobs.values())[-1]
            return {
                "running": running_job,
                "latest": latest,
                "count": len(self._jobs),
            }

    def get_job(self, job_id: str) -> JobStatus:
        with self._lock:
            status = self._jobs.get(job_id)
            if not status:
                raise HTTPException(status_code=404, detail="job not found")
            return status

    def list_jobs(self) -> list[str]:
        with self._lock:
            return list(self._jobs.keys())

    def cancel(self, job_id: str) -> JobStatus:
        with self._lock:
            status = self._jobs.get(job_id)
            if not status:
                raise HTTPException(status_code=404, detail="job not found")
            if status.status != "running":
                return status
            event = self._cancel_events.get(job_id)
            if event:
                event.set()
            return status


log_dir = os.environ.get("LOG_DIR", "/var/log/panther")
log_level = os.environ.get("LOG_LEVEL", "INFO")
setup_logging(log_level=log_level, log_dir=log_dir)  # type: ignore
logger = logging.getLogger(__name__)

es_url = os.environ.get("ES_URL", "http://localhost:9200")
api_key = os.environ.get("ES_API_KEY", "")
es_user = os.environ.get("ES_USER", "")
es_password = os.environ.get("ES_PASSWORD", "")
es_client = create_es_client(
    api_key=api_key,
    user=es_user,
    password=es_password,
    es_url=es_url,
)

mona_url = os.environ.get("MONA_URL", None)
data_root = os.environ.get("DATA_ROOT", None)

try:
    source = create_document_source(
        data_root=Path(data_root) if data_root else None,
        mona_url=mona_url,
    )
except (ValueError, FileNotFoundError) as exc:
    logger.error(str(exc))
    sys.exit(1)

index = os.environ.get("ES_INDEX", "patent-documents")

job_manager = JobManager(
    es=es_client,
    index=index,
    source=source,
)
app = FastAPI(title="panther API", version="0.1.0")


@app.post("/jobs", response_model=JobStatus)
async def start_job(request: JobRequest) -> JobStatus:
    return job_manager.start_job(request)


@app.get("/jobs")
async def get_current_job() -> dict[str, Any]:
    return job_manager.get_current()


@app.get("/jobs/list", response_model=list[str])
async def get_job_list() -> list[str]:
    return job_manager.list_jobs()


@app.get("/jobs/{job_id}", response_model=JobStatus)
async def get_job(job_id: str) -> JobStatus:
    return job_manager.get_job(job_id)


@app.get("/jobs/{job_id}/cancel", response_model=JobStatus)
async def cancel_job(job_id: str) -> JobStatus:
    return job_manager.cancel(job_id)
