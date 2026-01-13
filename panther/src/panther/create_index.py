#!/usr/bin/env python3
"""
Create or update Elasticsearch index with mappings and settings from JSON file.

Usage:
    python create_index.py --index <index_name> --mapping <mapping_file> [--es-url <url>] [--recreate]
"""

import json
import sys
from pathlib import Path
from typing import Dict

from elasticsearch import Elasticsearch
from panther.es_client import create_es_client


def load_mapping_file(path: Path) -> Dict:
    """Load mapping and settings from JSON file."""
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)

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

