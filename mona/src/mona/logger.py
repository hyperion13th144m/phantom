import logging
import logging.handlers
from pathlib import Path

from pythonjsonlogger.json import JsonFormatter


def setup_logger(
    log_level: str = "info", log_path: Path = Path("/var/log/mona/mona.log")
):
    """
    ロガーの設定を行う
    - /var/log/mona にログを出力
    - ファイルサイズが1MBを超えたらローテーション
    - multiprocessor対応のためにRotatingFileHandlerを使用
    """
    handlers = []

    # ログファイルの出力先ディレクトリを作成
    log_path.parent.mkdir(parents=True, exist_ok=True)

    # コンソールハンドラーの設定
    console_handler = logging.StreamHandler()
    console_handler.setFormatter(
        logging.Formatter(
            "%(asctime)s %(processName)s %(levelname)s %(name)s: %(message)s"
        )
    )
    handlers.append(console_handler)

    # ファイルハンドラー（RotatingFileHandler）の設定
    # maxBytes=1024*1024(1MB)、backupCount=20でローテーション
    file_handler = logging.handlers.RotatingFileHandler(
        log_path,
        maxBytes=1024 * 1024,  # 1MB
        backupCount=20,
        encoding="utf-8",
    )
    file_handler.setFormatter(JsonFormatter())
    handlers.append(file_handler)

    # ルートロガーの設定
    root_logger = logging.getLogger()
    root_logger.setLevel(getattr(logging, log_level.upper(), logging.INFO))

    # setup_logger が複数回呼ばれても重複して出力されないようにする
    root_logger.handlers.clear()
    for handler in handlers:
        root_logger.addHandler(handler)
