#!/usr/bin/env python3
"""
Panther main CLI - Manage Elasticsearch index and upload documents

Usage:
    python main.py create-index --index <name> --mapping <file>
    python main.py upload --index <name> --data-root <path>
    python main.py upload-extra --index <name> --sqlite-db <file>
"""

import argparse
import logging
import logging.handlers
import os
import sys
from pathlib import Path

from panther.create_db import cmd_create_db
from panther.create_index import cmd_create_index
from panther.import_extra_data import cmd_import_extra_data
from panther.upload_documents import cmd_upload
from panther.upload_extra_data import cmd_upload_extra_data


def setup_logging():
    """Configure logging with rotating file handler."""
    log_dir = Path("/var/log/panther")
    log_file = log_dir / "panther.log"

    # Create log directory if it doesn't exist
    log_dir.mkdir(parents=True, exist_ok=True)

    # Set up the root logger
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)

    # Create rotating file handler (128KB max, keep 5 backup files)
    file_handler = logging.handlers.RotatingFileHandler(
        log_file, maxBytes=128 * 1024, backupCount=5, encoding="utf-8"  # 128 KB
    )
    file_handler.setLevel(logging.INFO)

    # Create console handler
    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.INFO)

    # Create formatter
    formatter = logging.Formatter(
        "%(asctime)s - %(name)s - %(levelname)s - %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )
    file_handler.setFormatter(formatter)
    console_handler.setFormatter(formatter)

    # Add handlers to logger
    logger.addHandler(file_handler)
    logger.addHandler(console_handler)

    logger.info("Logging initialized")


def add_common_arguments(parser: argparse.ArgumentParser):
    """Add common Elasticsearch connection arguments."""
    parser.add_argument(
        "--es",
        default=os.getenv("ES_URL", "http://localhost:9200"),
        help="Elasticsearch URL (default: $ES_URL or http://localhost:9200)",
    )
    parser.add_argument(
        "--api-key",
        default=os.getenv("ES_API_KEY"),
        help="Elastic API key (default: $ES_API_KEY)",
    )
    parser.add_argument(
        "--user",
        default=os.getenv("ES_USER"),
        help="Basic auth username (default: $ES_USER)",
    )
    parser.add_argument(
        "--password",
        default=os.getenv("ES_PASSWORD"),
        help="Basic auth password (default: $ES_PASSWORD)",
    )
    parser.add_argument(
        "--index",
        required=True,
        help="Elasticsearch index name",
    )


def main():
    """Main entry point with subcommands."""
    # Set up logging before anything else
    setup_logging()

    parser = argparse.ArgumentParser(
        description="Panther CLI - Elasticsearch index management and document upload",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    subparsers = parser.add_subparsers(dest="command", help="Available commands")

    # create-db subcommand
    create_db_parser = subparsers.add_parser(
        "create-db",
        help="Create table for storing extra data.",
    )
    create_db_parser.add_argument(
        "--sqlite-db",
        default="extra_patent_data.db",
        help="SQLite database file for storing extra data (default: extra_patent_data.db)",
    )

    # import-extra-data subcommand
    import_extra_data_parser = subparsers.add_parser(
        "import-extra-data",
        help="Import document.json files into extra data database.",
    )
    import_extra_data_parser.add_argument(
        "--data-dir",
        required=True,
        help="Directory containing docid/document.json files to import",
    )
    import_extra_data_parser.add_argument(
        "--sqlite-db",
        default="extra_patent_data.db",
        help="SQLite database file for storing extra data (default: extra_patent_data.db)",
    )

    # create-index subcommand
    create_parser = subparsers.add_parser(
        "create-index",
        help="Create or update Elasticsearch index with mappings",
    )
    add_common_arguments(create_parser)
    create_parser.add_argument(
        "--mapping",
        required=True,
        help="Path to mapping JSON file (contains settings and mappings)",
    )
    create_parser.add_argument(
        "--recreate",
        action="store_true",
        help="Delete and recreate index if it exists (WARNING: deletes all data)",
    )

    # upload subcommand
    upload_parser = subparsers.add_parser(
        "upload-documents",
        help="Upload documents to Elasticsearch",
    )
    add_common_arguments(upload_parser)
    upload_parser.add_argument(
        "--data-root",
        default="data",
        help="Root directory containing docid/document.json files (default: data)",
    )
    upload_parser.add_argument(
        "--pipeline",
        default=os.getenv("ES_PIPELINE"),
        help="Ingest pipeline name (default: $ES_PIPELINE)",
    )
    upload_parser.add_argument(
        "--chunk-size",
        type=int,
        default=500,
        help="Bulk chunk size (default: 500)",
    )
    upload_parser.add_argument(
        "--max-retries",
        type=int,
        default=5,
        help="Max retry attempts for transient failures (default: 5)",
    )
    upload_parser.add_argument(
        "--use-hash-guard",
        action="store_true",
        help="Skip updates if ingest_hash unchanged",
    )
    upload_parser.add_argument(
        "--refresh",
        action="store_true",
        help="Refresh index after bulk (slower but makes documents immediately searchable)",
    )

    # upload extra-data subcommand
    upload_extra_parser = subparsers.add_parser(
        "upload-extra-data",
        help="Upload extra data (assignees, tags) from SQLite to Elasticsearch",
    )
    add_common_arguments(upload_extra_parser)
    upload_extra_parser.add_argument(
        "--sqlite-db", required=True, help="Path to sqlite db"
    )
    upload_extra_parser.add_argument(
        "--batch", type=int, default=500, help="Bulk batch size"
    )
    upload_extra_parser.add_argument(
        "--dry-run", action="store_true", help="Do not write to ES"
    )

    args = parser.parse_args()

    # Show help if no command specified
    if not args.command:
        parser.print_help()
        return 1

    # Route to appropriate command handler
    if args.command == "create-index":
        return cmd_create_index(args)
    elif args.command == "upload-documents":
        return cmd_upload(args)
    elif args.command == "create-db":
        return cmd_create_db(args.sqlite_db)
    elif args.command == "import-extra-data":
        return cmd_import_extra_data(args.data_dir, args.sqlite_db)
    elif args.command == "upload-extra-data":
        return cmd_upload_extra_data(args)
    else:
        parser.print_help()
        return 1


if __name__ == "__main__":
    sys.exit(main())
