#!/usr/bin/env python3
"""
Panther main CLI - Manage Elasticsearch index and upload documents

Usage:
    python main.py create-index --index <name> --mapping <file>
    python main.py upload --index <name> --data-root <path>
"""

import argparse
import os
import sys
from pathlib import Path

# Import the main functions from submodules
from panther.create_index import create_or_update_index, load_mapping_file
from panther.upload_es import (
    build_actions,
    bulk_upsert_with_retries,
)
from elasticsearch import Elasticsearch


def create_es_client(args) -> Elasticsearch:
    """Create Elasticsearch client from common arguments."""
    if args.api_key:
        return Elasticsearch(args.es, api_key=args.api_key)
    elif args.user and args.password:
        return Elasticsearch(args.es, basic_auth=(args.user, args.password))
    else:
        return Elasticsearch(args.es)


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


def cmd_create_index(args) -> int:
    """Create or update Elasticsearch index with mappings."""
    # Validate mapping file exists
    mapping_path = Path(args.mapping)
    if not mapping_path.exists():
        print(f"Error: Mapping file not found: {mapping_path}", file=sys.stderr)
        return 1

    # Load mapping configuration
    try:
        mapping_config = load_mapping_file(mapping_path)
    except Exception as e:
        print(f"Error: Failed to load mapping file: {e}", file=sys.stderr)
        return 1

    # Connect to Elasticsearch
    print(f"Connecting to Elasticsearch: {args.es}")
    try:
        es = create_es_client(args)

        # Check connection
        if not es.ping():
            print("Error: Cannot connect to Elasticsearch", file=sys.stderr)
            return 1

        print("✓ Connected to Elasticsearch")

        # Create or update index
        create_or_update_index(es, args.index, mapping_config, args.recreate)

        # Show index info
        stats = es.indices.stats(index=args.index)
        total_docs = stats["indices"][args.index]["total"]["docs"]["count"]
        print(f"\nIndex info:")
        print(f"  Name: {args.index}")
        print(f"  Documents: {total_docs}")

        return 0

    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        return 1
    finally:
        if "es" in locals():
            es.close()


def cmd_upload(args) -> int:
    """Upload documents to Elasticsearch."""
    data_root = Path(args.data_root)
    if not data_root.exists():
        print(f"Error: Data root not found: {data_root}", file=sys.stderr)
        return 1

    # Connect to Elasticsearch
    print(f"Connecting to Elasticsearch: {args.es}")
    try:
        es = create_es_client(args)

        # Check connection
        if not es.ping():
            print("Error: Cannot connect to Elasticsearch", file=sys.stderr)
            return 1

        print("✓ Connected to Elasticsearch")
        print(f"Uploading documents from: {data_root}")

        # Build actions
        actions = build_actions(
            index=args.index,
            data_root=data_root,
            pipeline=args.pipeline,
            refresh=args.refresh,
            use_hash_guard=args.use_hash_guard,
        )

        # Bulk upsert with retries
        success, failed = bulk_upsert_with_retries(
            es,
            actions,
            chunk_size=args.chunk_size,
            max_retries=args.max_retries,
            initial_backoff=1.0,
            max_backoff=30.0,
        )

        if args.refresh:
            print("Refreshing index...")
            es.indices.refresh(index=args.index)

        print(f"\n[DONE] Success: {success}, Failed: {failed}")
        return 0 if failed == 0 else 1

    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        return 1
    finally:
        if "es" in locals():
            es.close()


def main():
    """Main entry point with subcommands."""
    parser = argparse.ArgumentParser(
        description="Panther CLI - Elasticsearch index management and document upload",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    subparsers = parser.add_subparsers(dest="command", help="Available commands")

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
        "upload",
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

    args = parser.parse_args()

    # Show help if no command specified
    if not args.command:
        parser.print_help()
        return 1

    # Route to appropriate command handler
    if args.command == "create-index":
        return cmd_create_index(args)
    elif args.command == "upload":
        return cmd_upload(args)
    else:
        parser.print_help()
        return 1


if __name__ == "__main__":
    sys.exit(main())
