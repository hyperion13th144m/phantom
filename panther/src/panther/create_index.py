#!/usr/bin/env python3
"""
Create or update Elasticsearch index with mappings and settings from JSON file.

Usage:
    python create_index.py --index <index_name> --mapping <mapping_file> [--es-url <url>] [--recreate]
"""

import argparse
import json
import sys
from pathlib import Path
from typing import Dict

from elasticsearch import Elasticsearch


def load_mapping_file(path: Path) -> Dict:
    """Load mapping and settings from JSON file."""
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def create_or_update_index(
    es: Elasticsearch, index_name: str, mapping_config: Dict, recreate: bool = False
) -> None:
    """
    Create or update Elasticsearch index with mappings and settings.

    Args:
        es: Elasticsearch client
        index_name: Name of the index to create/update
        mapping_config: Dict containing 'settings' and 'mappings'
        recreate: If True, delete existing index before creating
    """
    # Check if index exists
    exists = es.indices.exists(index=index_name)

    if exists and recreate:
        print(f"Deleting existing index: {index_name}")
        es.indices.delete(index=index_name)
        exists = False

    if not exists:
        # Create new index with settings and mappings
        print(f"Creating index: {index_name}")
        es.indices.create(index=index_name, body=mapping_config)
        print(f"✓ Index '{index_name}' created successfully")
    else:
        # Update mappings on existing index
        print(f"Index '{index_name}' already exists")

        # Update mappings (can add new fields, cannot modify existing)
        if "mappings" in mapping_config:
            print(f"Updating mappings for index: {index_name}")
            es.indices.put_mapping(index=index_name, body=mapping_config["mappings"])
            print(f"✓ Mappings updated successfully")

        # Note: Settings cannot be updated on open index except for dynamic settings
        if "settings" in mapping_config:
            print("⚠ Warning: Cannot update most settings on existing index.")
            print(
                "   Use --recreate flag to delete and recreate the index with new settings."
            )


def main():
    parser = argparse.ArgumentParser(
        description="Create or update Elasticsearch index with mappings from JSON file"
    )
    parser.add_argument(
        "--index", required=True, help="Name of the Elasticsearch index"
    )
    parser.add_argument(
        "--mapping",
        required=True,
        type=Path,
        help="Path to mapping JSON file (contains settings and mappings)",
    )
    parser.add_argument(
        "--es-url",
        default="http://localhost:9200",
        help="Elasticsearch URL (default: http://localhost:9200)",
    )
    parser.add_argument(
        "--user", help="Elasticsearch username (if authentication required)"
    )
    parser.add_argument(
        "--password", help="Elasticsearch password (if authentication required)"
    )
    parser.add_argument(
        "--recreate",
        action="store_true",
        help="Delete and recreate index if it exists (WARNING: deletes all data)",
    )

    args = parser.parse_args()

    # Validate mapping file exists
    if not args.mapping.exists():
        print(f"Error: Mapping file not found: {args.mapping}", file=sys.stderr)
        sys.exit(1)

    # Load mapping configuration
    try:
        mapping_config = load_mapping_file(args.mapping)
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON in mapping file: {e}", file=sys.stderr)
        sys.exit(1)

    # Connect to Elasticsearch
    print(f"Connecting to Elasticsearch: {args.es_url}")

    es_kwargs = {"hosts": [args.es_url]}
    if args.user and args.password:
        es_kwargs["basic_auth"] = (args.user, args.password)

    try:
        es = Elasticsearch(**es_kwargs)

        # Check connection
        if not es.ping():
            print("Error: Cannot connect to Elasticsearch", file=sys.stderr)
            sys.exit(1)

        print("✓ Connected to Elasticsearch")

        # Create or update index
        create_or_update_index(es, args.index, mapping_config, args.recreate)

        # Show index info
        stats = es.indices.stats(index=args.index)
        total_docs = stats["indices"][args.index]["total"]["docs"]["count"]
        print(f"\nIndex info:")
        print(f"  Name: {args.index}")
        print(f"  Documents: {total_docs}")

    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
    finally:
        if "es" in locals():
            es.close()


if __name__ == "__main__":
    main()
