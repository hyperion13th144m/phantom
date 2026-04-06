import argparse
import logging
import os
import sys
from pathlib import Path
from typing import Sequence

from panther.es_client import create_es_client
from panther.logger import setup_logging
from panther.document_source import create_document_source
from panther.upload_documents import execute_upload, format_upload_result_summary


def load_id_list_file(path: str) -> list[str]:
    ids: list[str] = []
    for raw_line in Path(path).read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        ids.append(line)
    return ids


def collect_requested_ids(
    explicit_ids: Sequence[str] | None,
    id_list_file: str | None,
) -> list[str] | None:
    requested_ids: list[str] = []
    if explicit_ids:
        requested_ids.extend(str(doc_id).strip() for doc_id in explicit_ids if str(doc_id).strip())
    if id_list_file:
        requested_ids.extend(load_id_list_file(id_list_file))
    if not requested_ids:
        return None

    deduped_ids: list[str] = []
    seen: set[str] = set()
    for doc_id in requested_ids:
        if doc_id in seen:
            continue
        seen.add(doc_id)
        deduped_ids.append(doc_id)
    return deduped_ids


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
    parser.add_argument(
        "--id",
        dest="id_list",
        action="append",
        default=None,
        help="Upload only the specified document id. Repeat to add multiple ids.",
    )
    parser.add_argument(
        "--id-list-file",
        help="Path to a UTF-8 text file containing one document id per line.",
    )
    return parser.parse_args()


def main():
    args = get_args()
    setup_logging(log_level=args.log_level, log_dir=args.log_dir)  # type: ignore
    logger = logging.getLogger(__name__)
    logger.info("Starting Panther CLI with arguments: %s", args)

    try:
        source = create_document_source(
            data_root=Path(args.data_root) if args.data_root else None,
            mona_url=args.mona_url,
        )
    except (ValueError, FileNotFoundError) as exc:
        logger.error(str(exc))
        return 1

    try:
        requested_ids = collect_requested_ids(args.id_list, args.id_list_file)
    except FileNotFoundError as exc:
        logger.error("ID list file not found: %s", exc.filename or exc)
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
        source=source,
        chunk_size=args.chunk_size,
        max_retries=args.max_retries,
        use_hash_guard=args.use_hash_guard,
        id_list=requested_ids,
    )
    logger.info(format_upload_result_summary(results))
    if results.requested_ids is not None:
        logger.info("Requested document ids: %s", results.requested_ids)
    if results.missing_ids:
        logger.warning("Missing document ids: %s", results.missing_ids)
    return 0


if __name__ == "__main__":
    sys.exit(main())
