import { asc, eq, inArray, sql } from "drizzle-orm";
import type { MetadataRecord, MetadataUpdateInput } from "../types/metadata";
import { db } from "./client";
import { documentMetadata, metadataHistory } from "./schema";

function nowIso(): string {
    return new Date().toISOString();
}

function parseJsonArray(value: string): string[] {
    try {
        const parsed = JSON.parse(value);
        return Array.isArray(parsed) ? parsed : [];
    } catch {
        return [];
    }
}

function toRecord(row: typeof documentMetadata.$inferSelect): MetadataRecord {
    return {
        docId: row.docId,
        assignees: parseJsonArray(row.assigneesJson),
        tags: parseJsonArray(row.tagsJson),
        extraNumbers: parseJsonArray(row.extraNumbersJson),
        memo: row.memo,
        checked: row.checked,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
    };
}

export async function getMetadataByDocId(
    docId: string,
): Promise<MetadataRecord | null> {
    const rows = await db
        .select()
        .from(documentMetadata)
        .where(eq(documentMetadata.docId, docId))
        .limit(1);

    if (rows.length === 0) return null;
    return toRecord(rows[0]);
}

export async function getMetadataByDocIds(
    docIds: string[],
): Promise<Map<string, MetadataRecord>> {
    if (docIds.length === 0) return new Map();

    const rows = await db
        .select()
        .from(documentMetadata)
        .where(inArray(documentMetadata.docId, docIds));

    return new Map(rows.map((row) => [row.docId, toRecord(row)]));
}

export async function upsertMetadata(
    docId: string,
    input: MetadataUpdateInput,
): Promise<{ before: MetadataRecord | null; after: MetadataRecord }> {
    const existing = await getMetadataByDocId(docId);
    const now = nowIso();

    const next: MetadataRecord = {
        docId,
        assignees: input.assignees ?? existing?.assignees ?? [],
        tags: input.tags ?? existing?.tags ?? [],
        extraNumbers: input.extraNumbers ?? existing?.extraNumbers ?? [],
        memo: input.memo ?? existing?.memo ?? "",
        checked: input.checked ?? existing?.checked ?? false,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
    };

    const values: typeof documentMetadata.$inferInsert = {
        docId: next.docId,
        assigneesJson: JSON.stringify(next.assignees),
        tagsJson: JSON.stringify(next.tags),
        extraNumbersJson: JSON.stringify(next.extraNumbers),
        memo: next.memo,
        checked: next.checked,
        createdAt: next.createdAt ?? now,
        updatedAt: next.updatedAt ?? now,
    };

    await db
        .insert(documentMetadata)
        .values(values)
        .onConflictDoUpdate({
            target: documentMetadata.docId,
            set: {
                assigneesJson: JSON.stringify(next.assignees),
                tagsJson: JSON.stringify(next.tags),
                extraNumbersJson: JSON.stringify(next.extraNumbers),
                memo: next.memo,
                checked: next.checked,
                updatedAt: next.updatedAt ?? now,
            },
        });

    return {
        before: existing,
        after: next,
    };
}

export async function insertMetadataHistory(params: {
    docId: string;
    operation: "create" | "update" | "bulk_update" | "sync";
    before: unknown;
    after: unknown;
}): Promise<void> {
    await db.insert(metadataHistory).values({
        docId: params.docId,
        operation: params.operation,
        beforeJson: JSON.stringify(params.before ?? null),
        afterJson: JSON.stringify(params.after ?? null),
        createdAt: nowIso(),
    });
}


export async function listMetadataPage(params?: {
    limit?: number;
    offset?: number;
}): Promise<MetadataRecord[]> {
    const limit = params?.limit ?? 1000;
    const offset = params?.offset ?? 0;

    const rows = await db
        .select()
        .from(documentMetadata)
        .orderBy(asc(documentMetadata.docId))
        .limit(limit)
        .offset(offset);

    return rows.map(toRecord);
}

export async function countMetadataRecords(): Promise<number> {
    const rows = await db.select({ count: sql<number>`count(*)` }).from(documentMetadata);
    return Number(rows[0]?.count ?? 0);
}