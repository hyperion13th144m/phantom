import logging
import os

from fastapi import FastAPI

from mona.server.routers import documents, jobs


def create_app(src_dir: str, data_dir: str, log_level: int = logging.INFO) -> FastAPI:
    app = FastAPI(title="mona API", version="0.1.0")
    app.include_router(documents.create_router(data_dir))
    app.include_router(jobs.create_router(src_dir, data_dir, log_level))
    return app


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

app = create_app(SRC_DIR, DATA_DIR, get_log_level())
