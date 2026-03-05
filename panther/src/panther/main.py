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

from panther.create_index import add_args as add_create_index_args
from panther.restore_metadata_to_es import add_args as add_restore_metadata_args
from panther.upload_documents import add_args as add_upload_args


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
        default=os.getenv("ES_INDEX"),
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
    add_common_arguments(parser)
    subparsers = parser.add_subparsers(dest="command", help="Available commands")
    add_create_index_args(subparsers)
    add_upload_args(subparsers)
    add_restore_metadata_args(subparsers)
    args = parser.parse_args()

    # Show help if no command specified
    if not args.command:
        parser.print_help()
        return 1

    if hasattr(args, "func"):
        return args.func(args)
    else:
        parser.print_help()
        return 1


if __name__ == "__main__":
    sys.exit(main())
