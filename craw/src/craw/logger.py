import json
import logging
import logging.config
from datetime import datetime
from pathlib import Path
from typing import Any

from craw.models.jobs import JobState

LOG_BASE_DIR = Path("/var/log/craw")
API_LOG_DIR = LOG_BASE_DIR / "api"
JOB_HISTORY_DIR = LOG_BASE_DIR / "jobs"
CRAWL_LOG_DIR = LOG_BASE_DIR / "crawling"


def save_job_state(job: JobState):
    file = JOB_HISTORY_DIR / f"{job.job_id}.json"
    with file.open("w", encoding="utf-8") as f:
        json.dump(job.to_model().model_dump(), f, ensure_ascii=False, indent=2)


def get_all_job_id() -> list[str]:
    jobs = []
    for file in JOB_HISTORY_DIR.glob("*.json"):
        jobs.append(file.stem)
    return jobs


def get_old_job_state(job_id: str) -> str:
    filename = JOB_HISTORY_DIR / f"{job_id}.json"
    if not filename.exists():
        raise FileNotFoundError(f"Log file for job {job_id} not found.")
    with filename.open("r", encoding="utf-8") as f:
        content = f.read()
    return content


def setup_api_logger():
    api_log = f"{API_LOG_DIR}/api.log"

    config: dict[str, Any] = {
        "version": 1,
        "disable_existing_loggers": False,
        "formatters": {
            "access_formatter": {
                "()": "uvicorn.logging.AccessFormatter",
                "format": '%(asctime)s [%(levelname)s] %(client_addr)s - "%(request_line)s" %(status_code)s',
                "datefmt": "%Y-%m-%d %H:%M:%S",
                "use_colors": False,
            },
        },
        "handlers": {
            "rotating_file_handler": {
                "class": "logging.handlers.TimedRotatingFileHandler",
                "filename": api_log,
                "when": "midnight",
                "interval": 1,
                "backupCount": 7,
                "encoding": "utf-8",
                "formatter": "access_formatter",
            },
        },
        "loggers": {
            "uvicorn.access": {
                "handlers": ["rotating_file_handler"],
                "level": "INFO",
                "propagate": False,
            },
        },
    }
    logging.config.dictConfig(config)


def setup_logger(job_id: str):
    timestamp = datetime.now().strftime("%Y%m%d")
    filename = f"{CRAWL_LOG_DIR}/{timestamp}_{job_id}.log"

    config: dict[str, Any] = {
        "version": 1,
        "disable_existing_loggers": False,
        "formatters": {
            "json_formatter": {
                "()": "pythonjsonlogger.jsonlogger.JsonFormatter",
                "format": "%(asctime)s [%(levelname)s] %(name)s: %(message)s",
                "datefmt": "%Y-%m-%d %H:%M:%S",
            },
        },
        "handlers": {
            "file_handler": {
                "class": "logging.FileHandler",
                "filename": filename,
                "formatter": "json_formatter",
            },
        },
        "loggers": {
            "craw.crawling": {
                "handlers": ["file_handler"],
                "level": "INFO",
                "propagate": False,
            },
        },
    }
    logging.config.dictConfig(config)
