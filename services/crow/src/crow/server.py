import logging
import os
from typing import List

from fastapi import BackgroundTasks, FastAPI, HTTPException
from fastapi.responses import JSONResponse

from crow.crawler.config import (
    DocCodeConfig,
    code_config,
    get_all_document_codes,
)
from crow.crawler.crawler import crawl
from crow.logger import (
    get_all_job_id,
    get_old_job_state,
    save_job_state,
    setup_api_logger,
    setup_logger,
)
from crow.models.jobs import JobRequest, JobResponse, JobState, JobStateModel


def create_app() -> FastAPI:
    # default は docker コンテナ起動でbind される先のディレクトリ
    src_dir = os.environ.get("SRC_DIR", "/src-dir")
    dst_dir = os.environ.get("DST_DIR", "/dst-dir")
    log_dir = os.environ.get("LOG_DIR", "/var/log/crow")
    log_level = os.environ.get("LOG_LEVEL", "INFO")

    app = FastAPI(title="crow API", version="0.1.0")
    setup_api_logger(log_dir, log_level)

    @app.get("/jobs/history", response_model=List[str])
    def list_jobs():
        return get_all_job_id(log_dir)

    @app.post("/jobs", response_model=JobResponse)
    def start_jobs(request: JobRequest, background_tasks: BackgroundTasks):
        global current_job
        if current_job is not None and current_job.status in ["queued", "running"]:
            raise HTTPException(status_code=409, detail="A job is already running.")

        job = JobState(request)
        job.status = "queued"
        current_job = job
        background_tasks.add_task(
            run_job,
            src_dir,
            dst_dir,
            job,
            request,
            log_dir,
            log_level,
        )
        return JobResponse(job_id=job.job_id, status=job.status)

    @app.get(
        "/jobs/status",
        response_model=JobStateModel,
        description="Get the status of the current job",
    )
    def get_job_status():
        if current_job is None:
            raise HTTPException(404, "No job found")
        return current_job.to_model().model_dump()

    @app.post("/jobs/cancel", response_model=JobResponse)
    def cancel_job():
        if current_job is None or current_job.status not in ["queued", "running"]:
            raise HTTPException(404, "No job running")
        current_job.request_cancel()
        return JobResponse(
            job_id=current_job.job_id,
            status=current_job.status,
            message="cancel_requested",
        )

    @app.get(
        "/jobs/{job_id}/log",
        description="Get the log of a completed job",
        response_model=JobStateModel,
    )
    def get_job_log(job_id: str) -> JSONResponse:
        try:
            content = get_old_job_state(job_id, log_dir)
            return JSONResponse(content=content)
        except FileNotFoundError as e:
            raise HTTPException(status_code=404, detail="Log file not found.") from e

    @app.get("/jobs/doc-codes", response_model=List[DocCodeConfig])
    def get_doc_codes():
        # Implement the logic to return available document codes
        return {
            "doc_codes_definitions": list(map(lambda x: x.model_dump(), code_config)),
            "available_doc_codes": get_all_document_codes(),
        }

    return app


def run_job(
    src_dir: str,
    dst_dir: str,
    job: JobState,
    options: JobRequest,
    log_dir: str,
    log_level: str,
):
    setup_logger(job.job_id, log_dir, log_level)
    logger = logging.getLogger("crow.crawling")

    try:
        request = JobRequest.model_validate(options)
    except Exception as e:
        job.fail(f"Invalid job options: {e}")
        logger.error(job.message)
        return

    logger.info(f"Starting job {job.job_id} with options: {request.model_dump()}")
    logger.info(f"Document codes1: {request.doc_codes}")
    logger.info(f"Document codes2: {request.get_doc_codes()}")
    try:
        job.run()

        for s in crawl(
            src_dir,
            dst_dir,
            overwrite=request.overwrite,
            doc_codes=request.get_doc_codes() or [],
            doc_id=request.doc_id,
            max_files=request.max_files,
        ):
            if job.cancel_requested:
                job.cancel()
                save_job_state(job, log_dir)
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
        save_job_state(job, log_dir)
    except Exception as e:
        logger.error(f"Job {job.job_id} failed: {e}", exc_info=True)
        job.fail(f"Job failed: {e}")
        save_job_state(job, log_dir)


# only one job at a time for now, so global variable is fine.
current_job: JobState | None = None

app = create_app()
