#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import os
import sqlite3
from dataclasses import dataclass
from typing import Any, Dict, Iterable, List, Optional, Tuple

from elasticsearch.helpers import bulk

from elasticsearch import Elasticsearch


@dataclass
class MetaRow:
    doc_id: str
    assignees: List[str]
    tags: List[str]
    extra_numbers: List[str]


def _parse_json_array(s: Optional[str]) -> List[str]:
    if not s:
        return []
    try:
        v = json.loads(s)
        if isinstance(v, list):
            return [str(x).strip() for x in v if str(x).strip()]
        return []
    except Exception:
        return []


def _connect_sqlite(sqlite_path: str) -> sqlite3.Connection:
    conn = sqlite3.connect(sqlite_path)
    conn.row_factory = sqlite3.Row
    return conn


def iter_meta_rows(
    conn: sqlite3.Connection,
    table: str,
    batch_size: int,
    offset: int = 0,
) -> Iterable[List[MetaRow]]:
    """
    Yields batches of MetaRow.
    Assumes columns: docId, assignees_json, tags_json, extraNumbers_json
    """
    cur = conn.cursor()

    while True:
        cur.execute(
            f"""
            SELECT docId, assignees_json, tags_json, extraNumbers_json
            FROM {table}
            ORDER BY docId
            LIMIT ? OFFSET ?
            """,
            (batch_size, offset),
        )
        rows = cur.fetchall()
        if not rows:
            break

        batch: List[MetaRow] = []
        for r in rows:
            doc_id = str(r["docId"])
            batch.append(
                MetaRow(
                    doc_id=doc_id,
                    assignees=_parse_json_array(r["assignees_json"]),
                    tags=_parse_json_array(r["tags_json"]),
                    extra_numbers=_parse_json_array(r["extraNumbers_json"]),
                )
            )

        yield batch
        offset += len(rows)


def count_rows(conn: sqlite3.Connection, table: str) -> int:
    cur = conn.cursor()
    cur.execute(f"SELECT COUNT(*) AS c FROM {table}")
    return int(cur.fetchone()["c"])


def make_es_client(args: argparse.Namespace) -> Elasticsearch:
    if args.api_key:
        return Elasticsearch(args.es_node, api_key=args.api_key)
    if args.es_user and args.es_password:
        return Elasticsearch(args.es_node, basic_auth=(args.es_user, args.es_password))
    return Elasticsearch(args.es_node)


def build_actions(
    index: str, batch: List[MetaRow], upsert: bool
) -> Iterable[Dict[str, Any]]:
    """
    Build bulk actions for ES.
    docId == _id の前提。
    """
    for r in batch:
        action: Dict[str, Any] = {
            "_op_type": "update",
            "_index": index,
            "_id": r.doc_id,
            "doc": {
                "assignees": r.assignees,
                "tags": r.tags,
                "extraNumbers": r.extra_numbers,
            },
        }
        if upsert:
            # 本文がESにないdocIdでもメタだけ作る（通常は非推奨）
            action["doc_as_upsert"] = True
        yield action


def main() -> int:
    p = argparse.ArgumentParser(
        description="Restore metadata from SQLite into Elasticsearch (bulk update)."
    )
    p.add_argument("--sqlite", required=True, help="Path to sqlite3 file")
    p.add_argument(
        "--table",
        default="patent_metadata",
        help="SQLite table name (default: patent_metadata)",
    )
    p.add_argument("--es-node", default=os.getenv("ES_NODE", "http://localhost:9200"))
    p.add_argument("--index", default=os.getenv("ES_INDEX", "patent-documents"))
    p.add_argument("--api-key", default=os.getenv("ES_API_KEY"))
    p.add_argument("--es-user", default=os.getenv("ES_USERNAME"))
    p.add_argument("--es-password", default=os.getenv("ES_PASSWORD"))
    p.add_argument(
        "--batch-size", type=int, default=int(os.getenv("BATCH_SIZE", "500"))
    )
    p.add_argument(
        "--refresh", action="store_true", help="Refresh index after each bulk (slower)"
    )
    p.add_argument(
        "--upsert",
        action="store_true",
        help="Use doc_as_upsert (creates docs if missing; usually avoid)",
    )
    args = p.parse_args()

    conn = _connect_sqlite(args.sqlite)
    total = count_rows(conn, args.table)
    print(f"metadata rows: {total}")

    es = make_es_client(args)

    processed = 0
    ok = 0
    not_found = 0
    failed = 0

    # streaming bulkで処理（メモリ節約）
    offset = 0
    for batch in iter_meta_rows(conn, args.table, args.batch_size, offset=offset):
        actions = build_actions(args.index, batch, upsert=args.upsert)

        # bulk() returns (success_count, errors)
        success_count, errors = bulk(
            es,
            actions,
            refresh=args.refresh,
            raise_on_error=False,
            raise_on_exception=False,
        )

        ok += int(success_count)
        processed += len(batch)

        # errors は update action 失敗の詳細リスト
        for e in errors:
            # e: {"update": {"_index":..., "_id":..., "status":..., "error":...}}
            upd = e.get("update") or {}
            status = upd.get("status")
            if status == 404:
                not_found += 1
            else:
                failed += 1

        print(
            f"progress: {processed}/{total}  ok={ok} notFound={not_found} failed={failed}"
        )

    print("done")
    print(
        {
            "total": total,
            "processed": processed,
            "ok": ok,
            "notFound": not_found,
            "failed": failed,
        }
    )
    return 0 if failed == 0 else 2


if __name__ == "__main__":
    raise SystemExit(main())
