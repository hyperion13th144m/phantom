import logging
import logging.config
from typing import Any

CLI_LOG_PATH = "/var/log/mona/mona.log"
SERVER_LOG_PATH = "/var/log/mona/mona.server.log"
ACCESS_LOG_PATH = "/var/log/mona/mona.access.log"
ERROR_LOG_PATH = "/var/log/mona/mona.error.log"

LOGGING_CONFIG: dict[str, Any] = {
    # ロギングの設定バージョン (固定で 1 を指定)
    "version": 1,
    # 既存のロガーを無効にしない (他のロガー設定を保持する)
    "disable_existing_loggers": False,
    # 【フォーマッターの設定】ログの出力フォーマットを定義
    "formatters": {
        "default": {
            "format": "%(asctime)s [%(levelname)s] %(name)s: %(message)s",
            "datefmt": "%Y-%m-%d %H:%M:%S",
        },
        "access": {
            "()": "uvicorn.logging.AccessFormatter",
            "format": '%(asctime)s [%(levelname)s] %(client_addr)s - "%(request_line)s" %(status_code)s',
            "datefmt": "%Y-%m-%d %H:%M:%S",
            "use_colors": False,
        },
    },
    # 【ハンドラーの設定】ログの出力先を定義
    "handlers": {
        # cli 用ローテーションファイル
        "cli_file": {
            "class": "logging.handlers.TimedRotatingFileHandler",
            "filename": CLI_LOG_PATH,
            "when": "midnight",  # 毎日0時にローテーション
            "interval": 1,
            "backupCount": 7,  # 7日分保持
            "encoding": "utf-8",
            "formatter": "default",
        },
        # rest api server 用ローテーションファイル
        "server_file": {
            "class": "logging.handlers.TimedRotatingFileHandler",
            "filename": SERVER_LOG_PATH,
            "when": "midnight",  # 毎日0時にローテーション
            "interval": 1,
            "backupCount": 7,  # 7日分保持
            "encoding": "utf-8",
            "formatter": "default",
        },
        # Uvicorn アクセスログ用ローテーションファイル
        "access_file": {
            "class": "logging.handlers.TimedRotatingFileHandler",
            "filename": ACCESS_LOG_PATH,
            "when": "midnight",
            "interval": 1,
            "backupCount": 7,
            "encoding": "utf-8",
            "formatter": "access",
        },
        "error_file": {
            "class": "logging.handlers.TimedRotatingFileHandler",
            "filename": ERROR_LOG_PATH,
            "when": "midnight",
            "interval": 1,
            "backupCount": 7,
            "encoding": "utf-8",
            "formatter": "default",
        },
        # コンソール出力
        "console": {
            "class": "logging.StreamHandler",
            "formatter": "default",
        },
    },
    # 【ロガーの設定】各ロガーが使用するハンドラーとログレベルを定義
    "loggers": {
        # CLI 用ロガー
        "mona.cli": {
            "handlers": ["cli_file", "console"],
            "level": "INFO",
            "propagate": False,
        },
        # REST API 用ロガー
        "mona.server": {
            "handlers": ["server_file", "console"],
            "level": "INFO",
            "propagate": False,
        },
        # Uvicorn のアクセスログ
        "uvicorn.access": {
            "handlers": ["access_file", "console"],
            "level": "INFO",
            "propagate": False,
        },
        # Uvicorn のエラーログ
        "uvicorn.error": {
            "handlers": ["error_file", "console"],
            "level": "INFO",
            "propagate": False,
        },
    },
}


def setup_logger():
    logging.config.dictConfig(LOGGING_CONFIG)
