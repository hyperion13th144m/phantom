import json
import logging
from pathlib import Path

from fastapi import APIRouter, BackgroundTasks, HTTPException
from fastapi.responses import JSONResponse

from mona.crawler.config import (
    code_config,
    get_all_document_codes,
    is_valid_document_code,
)
from mona.crawler.crawler import crawl
from mona.logger import setup_crawling_logger
from mona.server.models.jobs import JobOptions, JobState

# only one job at a time for now, so global variable is fine.
current_job: JobState | None = None

LOG_DIR = Path("/var/log/mona")
LOG_JOB_DIR = LOG_DIR / "jobs"
LOG_JOB_DIR.mkdir(parents=True, exist_ok=True)
LOG_LEVEL = logging.INFO


def create_router(src_dir: str, data_dir: str, log_level: int = LOG_LEVEL) -> APIRouter:
    global LOG_LEVEL

    # tags for Swagger UI
    router = APIRouter(prefix="/jobs", tags=["jobs"])
    LOG_LEVEL = log_level

    ### REST API /jobs/*
    @router.get("/jobs/history")
    def list_jobs():
        jobs = []
        for file in LOG_JOB_DIR.glob("*.json"):
            jobs.append(file.stem)
        return jobs

    @router.post("/jobs")
    def start_jobs(payload: dict, background_tasks: BackgroundTasks):
        global current_job
        if current_job is not None and current_job.status in ["queued", "running"]:
            raise HTTPException(status_code=409, detail="A job is already running.")

        job = JobState()
        job.status = "queued"
        current_job = job
        background_tasks.add_task(run_job, src_dir, data_dir, job, payload)
        return {"job_id": job.job_id, "status": job.status}

    @router.get("/jobs/status")
    def get_job_status():
        if current_job is None:
            raise HTTPException(404, "No job found")
        return current_job.to_model().model_dump_json(ensure_ascii=False, indent=2)

    @router.post("/jobs/cancel")
    def cancel_job():
        if current_job is None or current_job.status not in ["queued", "running"]:
            raise HTTPException(404, "No job running")
        current_job.request_cancel()
        return {"status": "cancel_requested"}

    @router.get("/jobs/{job_id}/log")
    def get_job_log(job_id: str) -> JSONResponse:
        filename = LOG_JOB_DIR / f"{job_id}.json"
        if not filename.exists():
            raise HTTPException(status_code=404, detail="Log file not found.")
        with filename.open("r", encoding="utf-8") as f:
            content = f.read()
        return JSONResponse(content=content)

    @router.get("/jobs/doc-codes")
    def get_doc_codes():
        # Implement the logic to return available document codes
        return {
            "doc_codes_definitions": code_config,
            "available_doc_codes": get_all_document_codes(),
        }

    return router


def run_job(src_dir: str, data_dir: str, job: JobState, options: dict):
    setup_crawling_logger(job.job_id)
    logger = logging.getLogger("mona.crawling")
    logger.setLevel(LOG_LEVEL)

    try:
        job_opts = JobOptions.model_validate(options)
    except Exception as e:
        job.fail(f"Invalid job options: {e}")
        logger.error(job.message)
        return

    if job_opts.doc_codes and is_valid_document_code(job_opts.doc_codes) is False:
        job.fail(f"Invalid document codes: {job_opts.doc_codes}")
        logger.error(job.message)
        return
    logger.info(f"Starting job {job.job_id} with options: {job_opts.model_dump()}")

    try:
        job.run()

        for s in crawl(
            src_dir,
            data_dir,
            overwrite=job_opts.overwrite,
            doc_codes=job_opts.doc_codes or [],
            doc_id=job_opts.doc_id,
            max_files=job_opts.max_files,
        ):
            if job.cancel_requested:
                job.cancel()
                save_job_history(job)
                return

            job.progress(
                doc_id=s.doc_id,
                archive_path=str(s.archive_path),
                status=s.status,
                message=s.error_message,
            )

            logger.debug(
                "Finished processing an archive",
                extra={
                    "doc_id": s.doc_id,
                    "archive_path": str(s.archive_path),
                    "output_json_dir": str(s.output_json_dir)
                    if s.output_json_dir
                    else None,
                    "status": s.status,
                    "error_message": s.error_message or "",
                },
            )
        job.complete()
        save_job_history(job)
    except Exception as e:
        logger.error(f"Job {job.job_id} failed: {e}", exc_info=True)
        job.fail(f"Job failed: {e}")
        save_job_history(job)


def save_job_history(job: JobState):
    file = LOG_DIR / "jobs" / f"{job.job_id}.json"
    with file.open("w", encoding="utf-8") as f:
        json.dump(job.to_model().model_dump(), f, ensure_ascii=False, indent=2)
