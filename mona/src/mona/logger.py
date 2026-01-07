import logging
from logging import DEBUG, INFO, StreamHandler, getLogger
from typing import Literal


def setup_logger():
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    )


def build_logger(level: Literal["info", "debug"] = "info"):
    if level == "info":
        lv = INFO
    else:
        lv = DEBUG
    logger = getLogger(__name__)
    handler = StreamHandler()
    handler.setLevel(lv)
    logger.setLevel(lv)
    logger.addHandler(handler)
    logger.propagate = False
    return logger
