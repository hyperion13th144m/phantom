import json
import logging
import logging.config
from datetime import datetime
from pathlib import Path
from typing import Any

from crow.models.jobs import JobState


def save_job_state(job: JobState, log_dir: str):
    job_history_dir = Path(log_dir) / "jobs"
    file = job_history_dir / f"{job.job_id}.json"
    with file.open("w", encoding="utf-8") as f:
        json.dump(job.to_model().model_dump(), f, ensure_ascii=False, indent=2)


def get_all_job_id(log_dir: str) -> list[str]:
    job_history_dir = Path(log_dir) / "jobs"
    jobs = []
    for file in job_history_dir.glob("*.json"):
        jobs.append(file.stem)
    return jobs


def get_old_job_state(job_id: str, log_dir: str) -> str:
    filename = Path(log_dir) / "jobs" / f"{job_id}.json"
    if not filename.exists():
        raise FileNotFoundError(f"Log file for job {job_id} not found.")
    with filename.open("r", encoding="utf-8") as f:
        content = f.read()
    return content


def setup_api_logger(log_dir: str, log_level: str):
    api_log_dir = Path(log_dir) / "api"
    api_log = f"{api_log_dir}/api.log"

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
                "delay": True,
                "suffix": "%Y%m%d",
                "formatter": "access_formatter",
            },
        },
        "loggers": {
            "uvicorn.access": {
                "handlers": ["rotating_file_handler"],
                "level": log_level,
                "propagate": False,
            },
        },
    }
    logging.config.dictConfig(config)


def setup_logger(job_id: str, log_dir: str, log_level: str):
    crawl_log_dir = Path(log_dir) / "crawling"
    timestamp = datetime.now().strftime("%Y%m%d")
    filename = f"{crawl_log_dir}/{timestamp}_{job_id}.log"

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
            "crow.crawling": {
                "handlers": ["file_handler"],
                "level": log_level,
                "propagate": False,
            },
        },
    }
    logging.config.dictConfig(config)


def setup_cli_logger(log_level: str):
    config: dict[str, Any] = {
        "version": 1,
        "disable_existing_loggers": False,
        "formatters": {
            "formatter": {
                "format": "%(asctime)s - %(name)s - %(levelname)s - %(message)s",
                "datefmt": "%Y-%m-%d %H:%M:%S",
            },
        },
        "handlers": {
            "stream_handler": {
                "class": "logging.StreamHandler",
                "formatter": "formatter",
            },
        },
        "loggers": {
            "crow.cli": {
                "handlers": ["stream_handler"],
                "level": log_level,
                "propagate": False,
            },
        },
    }
    logging.config.dictConfig(config)
