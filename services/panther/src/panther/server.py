import argparse
import logging
import os
import threading
import uuid
from datetime import datetime, timezone
from typing import Any, Literal

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field

from panther.upload_documents import UploadCancelledError, execute_upload

logger = logging.getLogger(__name__)


class JobRequest(BaseModel):
    index: str = Field(default_factory=lambda: os.getenv("ES_INDEX", ""))
    mona_base_url: str = Field(
        default_factory=lambda: os.getenv("MONA_BASE_URL", "http://localhost:8000")
    )
    es: str = Field(
        default_factory=lambda: os.getenv("ES_URL", "http://localhost:9200")
    )
    api_key: str | None = Field(default_factory=lambda: os.getenv("ES_API_KEY"))
    user: str | None = Field(default_factory=lambda: os.getenv("ES_USER"))
    password: str | None = Field(default_factory=lambda: os.getenv("ES_PASSWORD"))
    chunk_size: int = 500
    max_retries: int = 5
    use_hash_guard: bool = False


class JobStatus(BaseModel):
    job_id: str
    status: Literal["running", "completed", "failed", "cancelled"]
    started_at: str
    finished_at: str | None = None
    total: int = 0
    success: int = 0
    failed: int = 0
    source: str | None = None
    error: str | None = None


def utc_now_iso() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds")


class JobManager:
    def __init__(self):
        self._lock = threading.Lock()
        self._jobs: dict[str, JobStatus] = {}
        self._cancel_events: dict[str, threading.Event] = {}
        self._running_job_id: str | None = None

    def start_job(self, request: JobRequest) -> JobStatus:
        with self._lock:
            if self._running_job_id:
                raise HTTPException(
                    status_code=409, detail="Another job is already running"
                )

            if not request.index:
                raise HTTPException(status_code=400, detail="index is required")

            job_id = str(uuid.uuid4())
            status = JobStatus(
                job_id=job_id, status="running", started_at=utc_now_iso()
            )
            self._jobs[job_id] = status
            cancel_event = threading.Event()
            self._cancel_events[job_id] = cancel_event
            self._running_job_id = job_id

        worker = threading.Thread(
            target=self._run_job, args=(job_id, request, cancel_event), daemon=True
        )
        worker.start()
        return status

    def _run_job(
        self, job_id: str, request: JobRequest, cancel_event: threading.Event
    ) -> None:
        try:
            args = argparse.Namespace(
                data_root="data",
                mona_base_url=request.mona_base_url,
                index=request.index,
                chunk_size=request.chunk_size,
                max_retries=request.max_retries,
                use_hash_guard=request.use_hash_guard,
                es=request.es,
                api_key=request.api_key,
                user=request.user,
                password=request.password,
            )
            result = execute_upload(args, should_cancel=cancel_event.is_set)
            new_status = JobStatus(
                job_id=job_id,
                status="completed",
                started_at=self._jobs[job_id].started_at,
                finished_at=utc_now_iso(),
                total=int(result["total"]),
                success=int(result["success"]),
                failed=int(result["failed"]),
                source=str(result["source"]),
            )
            self._update_job(job_id, new_status)
        except UploadCancelledError:
            cancelled = self._jobs[job_id].model_copy(
                update={"status": "cancelled", "finished_at": utc_now_iso()}
            )
            self._update_job(job_id, cancelled)
        except Exception as exc:
            failed = self._jobs[job_id].model_copy(
                update={
                    "status": "failed",
                    "finished_at": utc_now_iso(),
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


job_manager = JobManager()
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
