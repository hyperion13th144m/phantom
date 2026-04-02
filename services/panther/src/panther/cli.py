import argparse
import logging
import os
import re
import sys
from pathlib import Path

import uvicorn

from panther.es_client import create_es_client
from panther.logger import setup_logging
from panther.upload_documents import execute_upload


def get_args():
    """Add common Elasticsearch connection arguments."""
    parser = argparse.ArgumentParser(
        description="Panther CLI - Elasticsearch index management and document upload",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "--es",
        default=os.environ.get("ES_URL", "http://localhost:9200"),
        help="Elasticsearch URL",
    )
    parser.add_argument(
        "--api-key",
        default=os.environ.get("ES_API_KEY"),
        help="Elastic API key",
    )
    parser.add_argument(
        "--user",
        default=os.environ.get("ES_USER"),
        help="Basic auth username",
    )
    parser.add_argument(
        "--password",
        default=os.environ.get("ES_PASSWORD"),
        help="Basic auth password",
    )
    parser.add_argument(
        "--index",
        default=os.environ.get("ES_INDEX", "patent-documents"),
        help="Elasticsearch index name",
    )
    parser.add_argument(
        "-l",
        "--log-level",
        default="INFO",
        choices=["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"],
        help="Logging level (default: INFO)",
    )
    parser.add_argument(
        "-d",
        "--log_dir",
        default="/var/log/panther",
        help="Directory to store log files (default: /var/log/panther)",
    )
    parser.add_argument(
        "--data-root",
        help="Root directory containing full-text.json files",
    )
    parser.add_argument(
        "--mona-url",
        help="Base URL of mona API server, e.g. http://localhost:8000",
    )
    parser.add_argument(
        "--chunk-size",
        type=int,
        default=500,
        help="Bulk chunk size (default: 500)",
    )
    parser.add_argument(
        "--max-retries",
        type=int,
        default=5,
        help="Max retry attempts for transient failures (default: 5)",
    )
    parser.add_argument(
        "--use-hash-guard",
        action="store_true",
        default=False,
        help="Skip updates if ingest_hash unchanged",
    )
    return parser.parse_args()


def main():
    args = get_args()
    setup_logging(log_level=args.log_level, log_dir=args.log_dir)  # type: ignore
    logger = logging.getLogger(__name__)
    logger.info("Starting Panther CLI with arguments: %s", args)

    if args.data_root:
        if args.mona_url:
            logger.warning(
                "Both --data-root and --mona-url provided. args.data_root is used."
            )
        mona_url = None
        data_root = Path(args.data_root)
    elif args.mona_url:
        mona_url = args.mona_url
        data_root = None
    else:
        logger.error("Either --data-root or --mona-url must be provided.")
        return 1

    if data_root and not data_root.is_dir():
        logger.error("Data root directory does not exist: %s", data_root)
        return 1

    if mona_url and re.match(r"^https?://", mona_url) is None:
        logger.error("Invalid Mona base URL: %s", mona_url)
        return 1

    logger.info("execute upload in cli mode.")
    es_client = create_es_client(
        api_key=args.api_key,
        user=args.user,
        password=args.password,
        es_url=args.es,
    )
    results = execute_upload(
        es_client,
        args.index,
        data_root if data_root else None,
        mona_url,
        chunk_size=args.chunk_size,
        max_retries=args.max_retries,
        use_hash_guard=args.use_hash_guard,
    )
    logger.info("Upload completed with results: %s", results)
    return 0


if __name__ == "__main__":
    sys.exit(main())
