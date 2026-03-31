import logging
import logging.config
import os
from pathlib import Path
from typing import Any

LOG_DIR = Path(os.environ.get("LOG_DIR", "/var/log/mona"))
ACCESS_LOG_PATH = LOG_DIR / "access.log"
ERROR_LOG_PATH = LOG_DIR / "error.log"


def setup_logger():
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
                "filename": ACCESS_LOG_PATH,
                "when": "midnight",
                "interval": 1,
                "backupCount": 7,
                "encoding": "utf-8",
                "formatter": "access_formatter",
            },
            "server_file": {
                "class": "logging.handlers.TimedRotatingFileHandler",
                "filename": ERROR_LOG_PATH,
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
                "level": "INFO",
                "propagate": False,
            },
            "uvicorn.access": {
                "handlers": ["access_file", "console"],
                "level": "INFO",
                "propagate": False,
            },
        },
    }
    logging.config.dictConfig(config)
