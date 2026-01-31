import logging
import logging.handlers
from pathlib import Path


def setup_logger():
    """
    ロガーの設定を行う
    - /var/log/mona にログを出力
    - ファイルサイズが128KBを超えたらローテーション
    - multiprocessor対応のためにRotatingFileHandlerを使用
    """
    log_dir = Path("/var/log/mona")
    log_dir.mkdir(parents=True, exist_ok=True)
    log_file = log_dir / "mona.log"

    # ルートロガーの設定
    root_logger = logging.getLogger()
    root_logger.setLevel(logging.INFO)

    # 既存のハンドラーをクリア（重複を防ぐ）
    root_logger.handlers.clear()

    # フォーマッターの設定
    formatter = logging.Formatter(
        "%(asctime)s [%(levelname)s] %(processName)s-%(process)d %(name)s: %(message)s"
    )

    # ファイルハンドラー（RotatingFileHandler）の設定
    # maxBytes=128KB、backupCount=5でローテーション
    file_handler = logging.handlers.RotatingFileHandler(
        log_file,
        maxBytes=128 * 1024,  # 128KB
        backupCount=5,
        encoding="utf-8",
    )
    file_handler.setLevel(logging.INFO)
    file_handler.setFormatter(formatter)
    root_logger.addHandler(file_handler)

    # コンソールハンドラーの設定
    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.INFO)
    console_handler.setFormatter(formatter)
    root_logger.addHandler(console_handler)
