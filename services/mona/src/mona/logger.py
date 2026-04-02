import logging
import logging.config
from pathlib import Path
from typing import Any


def setup_logger(log_dir: Path, log_level: str = "INFO") -> None:
    access_log_path = log_dir / "access.log"
    error_log_path = log_dir / "error.log"
    config: dict[str, Any] = {
        "version": 1,
        "disable_existing_loggers": False,
        "formatters": {
            "default_formatter": {
                "format": "%(asctime)s [%(levelname)s] %(name)s: %(message)s",
                "datefmt": "%Y-%m-%d %H:%M:%S",
            },
            "access_formatter": {
                "()": "uvicorn.logging.AccessFormatter",
                "format": '%(asctime)s [%(levelname)s] %(client_addr)s - "%(request_line)s" %(status_code)s',
                "datefmt": "%Y-%m-%d %H:%M:%S",
                "use_colors": False,
            },
        },
        "handlers": {
            "console": {
                "class": "logging.StreamHandler",
                "formatter": "default_formatter",
            },
            "access_file": {
                "class": "logging.handlers.TimedRotatingFileHandler",
                "filename": access_log_path,
                "when": "midnight",
                "interval": 1,
                "backupCount": 7,
                "encoding": "utf-8",
                "formatter": "access_formatter",
            },
            "server_file": {
                "class": "logging.handlers.TimedRotatingFileHandler",
                "filename": error_log_path,
                "when": "midnight",
                "interval": 1,
                "backupCount": 7,
                "encoding": "utf-8",
                "formatter": "default_formatter",
            },
        },
        "loggers": {
            "mona.server": {
                "handlers": ["server_file", "console"],
                "level": log_level,
                "propagate": False,
            },
            "uvicorn.access": {
                "handlers": ["access_file", "console"],
                "level": log_level,
                "propagate": False,
            },
        },
    }
    logging.config.dictConfig(config)
