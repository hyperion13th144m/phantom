import logging
import logging.handlers
from multiprocessing import Queue
from pathlib import Path

from pythonjsonlogger.json import JsonFormatter


def setup_logger(
    log_level: str = "info", log_path: Path = Path("/var/log/mona/mona.log")
):
    """
    ロガーの設定を行う
    - /var/log/mona にログを出力
    - ファイルサイズが128KBを超えたらローテーション
    - multiprocessor対応のためにRotatingFileHandlerを使用
    """
    log_queue = Queue(-1)
    handlers = []

    # コンソールハンドラーの設定
    console_handler = logging.StreamHandler()
    console_handler.setFormatter(
        logging.Formatter(
            "%(asctime)s %(processName)s %(levelname)s %(name)s: %(message)s"
        )
    )
    handlers.append(console_handler)

    # ファイルハンドラー（RotatingFileHandler）の設定
    # maxBytes=128KB、backupCount=5でローテーション
    file_handler = logging.handlers.RotatingFileHandler(
        log_path,
        maxBytes=128 * 1024,  # 128KB
        backupCount=5,
        encoding="utf-8",
    )
    file_handler.setFormatter(JsonFormatter())
    handlers.append(file_handler)

    # ルートロガーの設定
    root_logger = logging.getLogger()
    root_logger.setLevel(getattr(logging, log_level.upper(), logging.INFO))

    listener = logging.handlers.QueueListener(
        log_queue, *handlers, respect_handler_level=True
    )
    listener.start()

    return log_queue, listener


def setup_child_logging(log_queue, log_level: str):
    qh = logging.handlers.QueueHandler(log_queue)
    root = logging.getLogger()

    # 既存ハンドラを消して、QueueHandler のみにする（重要）
    root.handlers = []
    root.addHandler(qh)
    root.setLevel(getattr(logging, log_level.upper(), logging.INFO))
