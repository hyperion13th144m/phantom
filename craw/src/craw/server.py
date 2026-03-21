import logging
import os
from pathlib import Path

from fastapi import BackgroundTasks, FastAPI, HTTPException
from fastapi.responses import JSONResponse

from craw.crawler.config import (
    code_config,
    get_all_document_codes,
    is_valid_document_code,
)
from craw.crawler.crawler import crawl
from craw.logger import (
    get_all_job_id,
    get_job_history,
    save_job_history,
    setup_api_logger,
    setup_logger,
)
from craw.server.models.jobs import JobOptions, JobState


def create_app(src_dir: str, data_dir: str) -> FastAPI:
    setup_api_logger()
    app = FastAPI(title="craw API", version="0.1.0")

    @app.get("/jobs/history")
    def list_jobs():
        return get_all_job_id()

    @app.post("/jobs")
    def start_jobs(payload: dict, background_tasks: BackgroundTasks):
        global current_job
        if current_job is not None and current_job.status in ["queued", "running"]:
            raise HTTPException(status_code=409, detail="A job is already running.")

        job = JobState()
        job.status = "queued"
        current_job = job
        background_tasks.add_task(run_job, job, payload)
        return {"job_id": job.job_id, "status": job.status}

    @app.get("/jobs/status")
    def get_job_status():
        if current_job is None:
            raise HTTPException(404, "No job found")
        return current_job.to_model().model_dump_json(ensure_ascii=False, indent=2)

    @app.post("/jobs/cancel")
    def cancel_job():
        if current_job is None or current_job.status not in ["queued", "running"]:
            raise HTTPException(404, "No job running")
        current_job.request_cancel()
        return {"status": "cancel_requested"}

    @app.get("/jobs/{job_id}/log")
    def get_job_log(job_id: str) -> JSONResponse:
        try:
            content = get_job_history(job_id)
            return JSONResponse(content=content)
        except FileNotFoundError as e:
            raise HTTPException(status_code=404, detail="Log file not found.") from e

    @app.get("/jobs/doc-codes")
    def get_doc_codes():
        # Implement the logic to return available document codes
        return {
            "doc_codes_definitions": code_config,
            "available_doc_codes": get_all_document_codes(),
        }

    return app


def run_job(job: JobState, options: dict):
    setup_logger(job.job_id)
    logger = logging.getLogger("craw.crawling")
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
            SRC_DIR,
            DATA_DIR,
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


def get_log_level():
    level = os.getenv("LOG_LEVEL", "INFO").upper()
    valid_levels = ["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"]
    if level not in valid_levels:
        print(f"Invalid LOG_LEVEL '{level}' specified. Defaulting to 'INFO'.")
        return logging.INFO
    return getattr(logging, level)


# docker コンテナ起動時に /data-dir に
# 実データがあるディレクトリがマウントされるので、決め打ちで良い。
SRC_DIR = "/src-dir"
DATA_DIR = "/data-dir"

# only one job at a time for now, so global variable is fine.
current_job: JobState | None = None

LOG_JOB_DIR = Path("/var/log/craw/jobs")
LOG_JOB_DIR.mkdir(parents=True, exist_ok=True)
LOG_LEVEL = get_log_level()

app = create_app(SRC_DIR, DATA_DIR)
