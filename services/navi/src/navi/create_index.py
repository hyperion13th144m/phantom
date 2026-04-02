#!/usr/bin/env python3
"""
Create or update Elasticsearch index with mappings and settings from JSON file.

Usage:
    python create_index.py --index <index_name> --mapping <mapping_file> [--es-url <url>] [--recreate]
"""

import argparse
import json
import logging
from pathlib import Path
from typing import Any, Dict, Protocol

from elasticsearch import Elasticsearch
from panther.es_client import create_es_client

logger = logging.getLogger(__name__)


class SupportsAddParser(Protocol):
    def add_parser(self, name: str, **kwargs: Any) -> argparse.ArgumentParser: ...


def add_args(parser: SupportsAddParser) -> None:
    p = parser.add_parser(
        "create-index",
        help="Create Elasticsearch index with mappings",
    )
    p.add_argument(
        "--mapping",
        required=True,
        help="Path to mapping JSON file (contains settings and mappings)",
    )
    p.add_argument(
        "--recreate",
        action="store_true",
        help="Delete and recreate index if it exists (WARNING: deletes all data)",
    )
    p.set_defaults(func=main)


def main(args: argparse.Namespace) -> int:
    """Create or update Elasticsearch index with mappings."""
    # Validate mapping file exists
    mapping_path = Path(args.mapping)
    if not mapping_path.exists():
        logger.error(f"Error: Mapping file not found: {mapping_path}")
        return 1

    # Load mapping configuration
    try:
        mapping_config = load_mapping_file(mapping_path)
    except Exception as e:
        logger.error(f"Error: Failed to load mapping file: {e}")
        return 1

    # Connect to Elasticsearch
    logger.info(f"Connecting to Elasticsearch: {args.es}")
    es = create_es_client(args)
    try:
        # Check connection
        if not es.ping():
            logger.error("Error: Cannot connect to Elasticsearch")
            return 1

        logger.info("✓ Connected to Elasticsearch")

        # Create or update index
        create_or_update_index(es, args.index, mapping_config, args.recreate)

        # Show index info
        stats = es.indices.stats(index=args.index)
        total_docs = stats["indices"][args.index]["total"]["docs"]["count"]
        logger.info("\nIndex info:")
        logger.info(f"  Name: {args.index}")
        logger.info(f"  Documents: {total_docs}")

        return 0

    except Exception as e:
        logger.error(f"Error: {e}")
        return 1
    finally:
        es.close()


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
        logger.info(f"Deleting existing index: {index_name}")
        es.indices.delete(index=index_name)
        exists = False

    if not exists:
        # Create new index with settings and mappings
        logger.info(f"Creating index: {index_name}")
        es.indices.create(index=index_name, body=mapping_config)
        logger.info(f"✓ Index '{index_name}' created successfully")
    else:
        # Update mappings on existing index
        logger.info(f"Index '{index_name}' already exists")

        # Update mappings (can add new fields, cannot modify existing)
        if "mappings" in mapping_config:
            logger.info(f"Updating mappings for index: {index_name}")
            es.indices.put_mapping(index=index_name, body=mapping_config["mappings"])
            logger.info("✓ Mappings updated successfully")

        # Note: Settings cannot be updated on open index except for dynamic settings
        if "settings" in mapping_config:
            logger.warning("⚠ Warning: Cannot update most settings on existing index.")
            logger.warning(
                "   Use --recreate flag to delete and recreate the index with new settings."
            )
