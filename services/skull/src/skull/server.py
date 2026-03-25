from __future__ import annotations

import json
import os
import sqlite3
from contextlib import contextmanager
from datetime import datetime, timezone
from typing import Any

from fastapi import FastAPI, HTTPException, Query
from pydantic import BaseModel, Field

SQLITE_PATH = os.getenv("SQLITE_PATH", "metadata.sqlite3")


class MetadataRow(BaseModel):
    docId: str
    assignees_json: str
    tags_json: str
    extraNumbers_json: str
    updatedAt: str
    updatedBy: str | None
    version: int


class MetadataItem(BaseModel):
    docId: str
    assignees: list[str]
    tags: list[str]
    extraNumbers: list[str]
    updatedAt: str
    updatedBy: str | None
    version: int


class UpdateItem(BaseModel):
    docId: str = Field(min_length=1)
    assignees: Any | None = None
    tags: Any | None = None
    extraNumbers: Any | None = None
    updatedBy: str | None = None
    expectedVersion: int | None = None


class BulkUpdateRequest(BaseModel):
    updates: list[UpdateItem] = Field(min_length=1, max_length=2000)


class BulkUpdateResult(BaseModel):
    docId: str
    ok: bool
    status: int | None = None
    error: str | None = None
    version: int | None = None


class ByIdsRequest(BaseModel):
    docIds: list[str] = Field(min_length=1, max_length=2000)


class MetadataListResponse(BaseModel):
    page: int
    size: int
    total: int
    rows: list[MetadataItem]


app = FastAPI(title="skull API", version="0.1.0")


@contextmanager
def get_conn() -> sqlite3.Connection:
    conn = sqlite3.connect(SQLITE_PATH)
    conn.row_factory = sqlite3.Row
    try:
        yield conn
    finally:
        conn.close()


def now_iso() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds")


def normalize_list(value: Any, max_items: int) -> list[str]:
    if value is None:
        return []
    if not isinstance(value, list):
        raise ValueError("must be an array")

    out: list[str] = []
    seen: set[str] = set()
    for raw in value:
        if raw is None:
            continue
        text = str(raw).strip()
        if not text or text in seen:
            continue
        out.append(text)
        seen.add(text)
        if len(out) >= max_items:
            break
    return out


def row_to_item(row: sqlite3.Row) -> MetadataItem:
    return MetadataItem(
        docId=row["docId"],
        assignees=json.loads(row["assignees_json"]),
        tags=json.loads(row["tags_json"]),
        extraNumbers=json.loads(row["extraNumbers_json"]),
        updatedAt=row["updatedAt"],
        updatedBy=row["updatedBy"],
        version=row["version"],
    )


@app.on_event("startup")
def startup() -> None:
    with get_conn() as conn:
        conn.execute("PRAGMA journal_mode=WAL")
        conn.execute(
            """
            CREATE TABLE IF NOT EXISTS patent_metadata (
              docId TEXT PRIMARY KEY,
              assignees_json TEXT NOT NULL DEFAULT '[]',
              tags_json TEXT NOT NULL DEFAULT '[]',
              extraNumbers_json TEXT NOT NULL DEFAULT '[]',
              updatedAt TEXT NOT NULL,
              updatedBy TEXT,
              version INTEGER NOT NULL DEFAULT 1
            )
            """
        )
        conn.commit()


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.get("/metadata", response_model=MetadataListResponse)
def list_metadata(
    page: int = Query(default=1, ge=1),
    size: int = Query(default=50, ge=1, le=200),
    q: str | None = None,
    tag: str | None = None,
    assignee: str | None = None,
    extra: str | None = None,
) -> MetadataListResponse:
    where: list[str] = []
    binds: list[Any] = []

    if q and q.strip():
        where.append("docId LIKE ?")
        binds.append(f"%{q.strip()}%")
    if tag and tag.strip():
        where.append("EXISTS (SELECT 1 FROM json_each(tags_json) WHERE value = ?)")
        binds.append(tag.strip())
    if assignee and assignee.strip():
        where.append("EXISTS (SELECT 1 FROM json_each(assignees_json) WHERE value = ?)")
        binds.append(assignee.strip())
    if extra and extra.strip():
        where.append("EXISTS (SELECT 1 FROM json_each(extraNumbers_json) WHERE value = ?)")
        binds.append(extra.strip())

    where_sql = f"WHERE {' AND '.join(where)}" if where else ""
    offset = (page - 1) * size

    with get_conn() as conn:
        total_row = conn.execute(
            f"SELECT COUNT(*) AS total FROM patent_metadata {where_sql}",
            binds,
        ).fetchone()
        rows = conn.execute(
            f"""
            SELECT docId, assignees_json, tags_json, extraNumbers_json, updatedAt, updatedBy, version
            FROM patent_metadata
            {where_sql}
            ORDER BY updatedAt DESC
            LIMIT ? OFFSET ?
            """,
            [*binds, size, offset],
        ).fetchall()

    return MetadataListResponse(
        page=page,
        size=size,
        total=(total_row["total"] if total_row else 0),
        rows=[row_to_item(r) for r in rows],
    )


@app.post("/metadata/byIds")
def by_ids(payload: ByIdsRequest) -> dict[str, dict[str, Any]]:
    placeholders = ",".join("?" for _ in payload.docIds)
    with get_conn() as conn:
        rows = conn.execute(
            f"""
            SELECT docId, assignees_json, tags_json, extraNumbers_json, updatedAt, updatedBy, version
            FROM patent_metadata
            WHERE docId IN ({placeholders})
            """,
            payload.docIds,
        ).fetchall()

    by_id: dict[str, dict[str, Any]] = {}
    for row in rows:
        item = row_to_item(row)
        by_id[item.docId] = item.model_dump()

    return {"byId": by_id}


@app.post("/metadata/bulk")
def bulk_update(payload: BulkUpdateRequest) -> dict[str, Any]:
    updated_at = now_iso()
    results: list[BulkUpdateResult] = []

    try:
        with get_conn() as conn:
            conn.execute("BEGIN")
            for update in payload.updates:
                current = conn.execute(
                    """
                    SELECT docId, assignees_json, tags_json, extraNumbers_json, version
                    FROM patent_metadata
                    WHERE docId = ?
                    """,
                    [update.docId],
                ).fetchone()

                current_version = current["version"] if current else 0
                if (
                    update.expectedVersion is not None
                    and current_version != update.expectedVersion
                ):
                    results.append(
                        BulkUpdateResult(
                            docId=update.docId,
                            ok=False,
                            status=409,
                            error="Version conflict",
                        )
                    )
                    continue

                try:
                    next_assignees = (
                        normalize_list(update.assignees, max_items=20)
                        if update.assignees is not None
                        else (
                            json.loads(current["assignees_json"]) if current else []
                        )
                    )
                    next_tags = (
                        normalize_list(update.tags, max_items=50)
                        if update.tags is not None
                        else (
                            json.loads(current["tags_json"]) if current else []
                        )
                    )
                    next_extra = (
                        normalize_list(update.extraNumbers, max_items=20)
                        if update.extraNumbers is not None
                        else (
                            json.loads(current["extraNumbers_json"]) if current else []
                        )
                    )
                except ValueError as exc:
                    results.append(
                        BulkUpdateResult(
                            docId=update.docId,
                            ok=False,
                            status=400,
                            error=str(exc),
                        )
                    )
                    continue

                next_version = current_version + 1
                conn.execute(
                    """
                    INSERT INTO patent_metadata
                    (docId, assignees_json, tags_json, extraNumbers_json, updatedAt, updatedBy, version)
                    VALUES (?, ?, ?, ?, ?, ?, ?)
                    ON CONFLICT(docId) DO UPDATE SET
                        assignees_json=excluded.assignees_json,
                        tags_json=excluded.tags_json,
                        extraNumbers_json=excluded.extraNumbers_json,
                        updatedAt=excluded.updatedAt,
                        updatedBy=excluded.updatedBy,
                        version=excluded.version
                    """,
                    [
                        update.docId,
                        json.dumps(next_assignees),
                        json.dumps(next_tags),
                        json.dumps(next_extra),
                        updated_at,
                        update.updatedBy,
                        next_version,
                    ],
                )
                results.append(
                    BulkUpdateResult(docId=update.docId, ok=True, version=next_version)
                )
            conn.commit()
    except sqlite3.Error as exc:
        raise HTTPException(status_code=500, detail=f"sqlite error: {exc}") from exc

    return {
        "updatedAt": updated_at,
        "results": [r.model_dump(exclude_none=True) for r in results],
    }
