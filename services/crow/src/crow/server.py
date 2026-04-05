import logging
import os
import threading
from typing import Any

from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse

from crow.crawler.config import DocCodeCategory, doc_code_config
from crow.crawler.crawler import crawl
from crow.logger import (
    get_all_job_id,
    get_old_job_state,
    save_job_state,
    setup_api_logger,
    setup_logger,
)
from crow.models.jobs import JobRequest, JobResponse, JobState, JobStateModel


class JobManager:
    def __init__(self, src_dir: str, dst_dir: str, log_dir: str, log_level: str):
        self._src_dir = src_dir
        self._dst_dir = dst_dir
        self._log_dir = log_dir
        self._log_level = log_level

        self._lock = threading.Lock()
        self._jobs: dict[str, JobState] = {}
        self._running_job_id: str | None = None

    def start_job(self, request: JobRequest) -> JobResponse:
        with self._lock:
            if self._running_job_id and self._jobs[self._running_job_id].status in {
                "queued",
                "running",
            }:
                raise HTTPException(status_code=409, detail="A job is already running.")

            job = JobState(request)
            job.status = "queued"
            self._jobs[job.job_id] = job
            self._running_job_id = job.job_id

        worker = threading.Thread(target=self._run_job, args=(job.job_id,), daemon=True)
        worker.start()
        return JobResponse(job_id=job.job_id, status=job.status)

    def _run_job(self, job_id: str) -> None:
        with self._lock:
            job = self._jobs[job_id]

        setup_logger(job.job_id, self._log_dir, self._log_level)
        crawling_logger = logging.getLogger("crow.crawling")

        try:
            request = JobRequest.model_validate(job.request)
        except Exception as exc:
            job.fail(f"Invalid job options: {exc}")
            save_job_state(job, self._log_dir)
            crawling_logger.error(job.message)
            self._clear_running_job(job_id)
            return

        crawling_logger.info(
            "Starting job %s with options: %s", job.job_id, request.model_dump()
        )

        try:
            job.run()
            for state in crawl(
                self._src_dir,
                self._dst_dir,
                overwrite=request.overwrite,
                doc_codes=request.doc_codes,
                doc_id=request.doc_id,
                max_files=request.max_files,
            ):
                if job.cancel_requested:
                    job.cancel()
                    save_job_state(job, self._log_dir)
                    return

                job.progress(
                    doc_id=state.doc_id,
                    archive_path=str(state.archive_path),
                    status=state.status,
                    message=state.error_message,
                )

                if state.status == "fail":
                    crawling_logger.error(
                        "Job %s failed: %s",
                        job.job_id,
                        job.message,
                        extra={
                            "doc_id": state.doc_id,
                            "archive_path": str(state.archive_path),
                            "error_message": state.error_message or "",
                        },
                    )

                elif state.status == "success":
                    crawling_logger.debug(
                        "Finished processing an archive",
                        extra={
                            "doc_id": state.doc_id,
                            "archive_path": str(state.archive_path),
                            "output_json_dir": str(state.output_json_dir)
                            if state.output_json_dir
                            else None,
                            "status": state.status,
                            "error_message": state.error_message or "",
                        },
                    )

            job.complete()
            save_job_state(job, self._log_dir)
        except Exception as exc:
            crawling_logger.error("Job %s failed: %s", job.job_id, exc, exc_info=True)
            job.fail(f"Job failed: {exc}")
            save_job_state(job, self._log_dir)
        finally:
            self._clear_running_job(job_id)

    def _clear_running_job(self, job_id: str) -> None:
        with self._lock:
            if self._running_job_id == job_id:
                self._running_job_id = None

    def get_current_job(self) -> JobStateModel:
        with self._lock:
            if not self._running_job_id:
                raise HTTPException(404, "No job found")
            return self._jobs[self._running_job_id].to_model()

    def cancel_current_job(self) -> JobResponse:
        with self._lock:
            if not self._running_job_id:
                raise HTTPException(404, "No job running")

            job = self._jobs[self._running_job_id]
            if job.status not in {"queued", "running"}:
                raise HTTPException(404, "No job running")

            job.request_cancel()
            return JobResponse(
                job_id=job.job_id,
                status=job.status,
                message="cancel_requested",
            )

    def list_jobs(self) -> list[str]:
        return get_all_job_id(self._log_dir)

    def get_job_log(self, job_id: str) -> Any:
        try:
            return get_old_job_state(job_id, self._log_dir)
        except FileNotFoundError as exc:
            raise HTTPException(status_code=404, detail="Log file not found.") from exc


# default は docker コンテナ起動でbind される先のディレクトリ
src_dir = os.environ.get("SRC_DIR", "/src-dir")
dst_dir = os.environ.get("DST_DIR", "/data-dir")
log_dir = os.environ.get("LOG_DIR", "/var/log/crow")
log_level = os.environ.get("LOG_LEVEL", "INFO")

app = FastAPI(title="crow API", version="0.1.0")
setup_api_logger(log_dir, log_level)

job_manager = JobManager(src_dir, dst_dir, log_dir, log_level)


@app.get("/jobs/history", response_model=list[str])
def list_jobs() -> list[str]:
    return job_manager.list_jobs()


@app.post("/jobs", response_model=JobResponse)
def start_jobs(request: JobRequest) -> JobResponse:
    return job_manager.start_job(request)


@app.get(
    "/jobs/status",
    response_model=JobStateModel,
    description="Get the status of the current job",
)
def get_job_status() -> JobStateModel:
    return job_manager.get_current_job()


@app.post("/jobs/cancel", response_model=JobResponse)
def cancel_job() -> JobResponse:
    return job_manager.cancel_current_job()


@app.get(
    "/jobs/{job_id}/log",
    description="Get the log of a completed job",
    response_model=JobStateModel,
)
def get_job_log(job_id: str) -> JSONResponse:
    content = job_manager.get_job_log(job_id)
    return JSONResponse(content=content)


@app.get("/jobs/available-codes", response_model=list[str])
def get_doc_codes() -> list[str]:
    return doc_code_config.get_available_codes()


@app.get("/jobs/codes-description", response_model=list[DocCodeCategory])
def get_doc_codes_description() -> list[DocCodeCategory]:
    return doc_code_config.config
