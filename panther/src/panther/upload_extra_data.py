#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import json
import logging
import sqlite3
from typing import Any, Dict, Iterable, List, Optional, Tuple

from elasticsearch import Elasticsearch, helpers

logger = logging.getLogger(__name__)

# ---------- utility ----------


def parse_list_field(value: Optional[str]) -> Optional[List[str]]:
    """
    SQLite TEXT → List[str]
    - None / 空 → None（更新しない）
    - JSON配列 → そのまま
    - カンマ区切り → split
    """
    if value is None:
        return None

    value = value.strip()
    if not value:
        return None

    # JSON配列を優先
    if value.startswith("["):
        try:
            data = json.loads(value)
            if isinstance(data, list):
                return [str(x) for x in data if str(x).strip()]
        except json.JSONDecodeError:
            pass

    # カンマ区切り
    return [v.strip() for v in value.split(",") if v.strip()]


# ---------- sqlite ----------


def iter_sqlite_records(
    db_path: str,
) -> Iterable[Tuple[str, Optional[List[str]], Optional[List[str]]]]:
    """
    patentDocument から (docId, assignees, tags) を返す
    """
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    cur = conn.cursor()

    cur.execute(
        """
        SELECT docId, assignees, tags
        FROM patentDocument
    """
    )

    for row in cur:
        doc_id = row["docId"]
        assignees = parse_list_field(row["assignees"])
        tags = parse_list_field(row["tags"])
        yield doc_id, assignees, tags

    conn.close()


# ---------- elasticsearch ----------


def build_actions(
    index: str,
    records: Iterable[Tuple[str, Optional[List[str]], Optional[List[str]]]],
) -> Iterable[Dict[str, Any]]:
    """
    bulk update actions
    """
    for doc_id, assignees, tags in records:
        doc: Dict[str, Any] = {}

        if assignees is not None:
            doc["assignees"] = assignees

        if tags is not None:
            doc["tags"] = tags

        # 更新するものが無い場合はスキップ
        if not doc:
            continue

        yield {
            "_op_type": "update",
            "_index": index,
            "_id": doc_id,
            "doc": doc,
            # doc_as_upsert=False:
            # - ES側に無い docId は作らない
            # - 「ユーザー編集用フィールド同期」用途として安全
            "doc_as_upsert": False,
        }


# ---------- main ----------


def cmd_upload_extra_data(args):
    # ES client
    if args.api_key:
        es = Elasticsearch(args.es, api_key=args.api_key)
    elif args.user and args.password:
        es = Elasticsearch(args.es, basic_auth=(args.user, args.password))
    else:
        es = Elasticsearch(args.es)

    records = list(iter_sqlite_records(args.sqlite_db))
    actions = list(build_actions(args.index, records))

    logger.info(f"SQLite records: {len(records)}")
    logger.info(f"ES updates:     {len(actions)}")

    if args.dry_run:
        for a in actions[:5]:
            logger.info(f"[DRY] {a['_id']} {a['doc']}")
        return 0

    helpers.bulk(
        es,
        actions,
        chunk_size=args.batch,
        raise_on_error=False,
        raise_on_exception=False,
    )

    logger.info("Done.")
    return 0
