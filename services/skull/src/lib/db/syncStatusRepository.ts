import { desc, eq, inArray, or, sql } from "drizzle-orm";
import type {
    MetadataSyncState,
    MetadataSyncStatusRecord,
} from "../types/sync";
import { db } from "./client";
import { metadataSyncStatus } from "./schema";

function nowIso(): string {
    return new Date().toISOString();
}

function toRecord(
    row: typeof metadataSyncStatus.$inferSelect,
): MetadataSyncStatusRecord {
    return {
        docId: row.docId,
        syncStatus: row.syncStatus as MetadataSyncState,
        errorMessage: row.errorMessage,
        retryCount: row.retryCount,
        lastAttemptedAt: row.lastAttemptedAt ?? null,
        lastSucceededAt: row.lastSucceededAt ?? null,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
    };
}

export async function getSyncStatusByDocId(
    docId: string,
): Promise<MetadataSyncStatusRecord | null> {
    const rows = await db
        .select()
        .from(metadataSyncStatus)
        .where(eq(metadataSyncStatus.docId, docId))
        .limit(1);

    if (rows.length === 0) return null;
    return toRecord(rows[0]);
}

export async function getSyncStatusesByDocIds(
    docIds: string[],
): Promise<Map<string, MetadataSyncStatusRecord>> {
    if (docIds.length === 0) return new Map();

    const rows = await db
        .select()
        .from(metadataSyncStatus)
        .where(inArray(metadataSyncStatus.docId, docIds));

    return new Map(rows.map((row) => [row.docId, toRecord(row)]));
}

export async function getDocIdsBySyncStatus(
    syncStatus: MetadataSyncState,
    limit = 1000,
): Promise<string[]> {
    const rows = await db
        .select({ docId: metadataSyncStatus.docId })
        .from(metadataSyncStatus)
        .where(eq(metadataSyncStatus.syncStatus, syncStatus))
        .limit(limit);

    return rows.map((row) => row.docId);
}

export async function listUnsyncedStatuses(params?: {
    statuses?: MetadataSyncState[];
    limit?: number;
    offset?: number;
}): Promise<MetadataSyncStatusRecord[]> {
    const statuses = params?.statuses?.length
        ? params.statuses
        : (["pending", "failed"] as MetadataSyncState[]);
    const limit = params?.limit ?? 100;
    const offset = params?.offset ?? 0;

    const conditions = statuses.map((status) =>
        eq(metadataSyncStatus.syncStatus, status),
    );

    const rows = await db
        .select()
        .from(metadataSyncStatus)
        .where(or(...conditions))
        .orderBy(
            desc(
                sql`CASE ${metadataSyncStatus.syncStatus}
            WHEN 'failed' THEN 2
            WHEN 'pending' THEN 1
            ELSE 0
          END`,
            ),
            desc(metadataSyncStatus.updatedAt),
        )
        .limit(limit)
        .offset(offset);

    return rows.map(toRecord);
}

export async function countBySyncStatuses(
    statuses?: MetadataSyncState[],
): Promise<number> {
    const target = statuses?.length
        ? statuses
        : (["pending", "failed"] as MetadataSyncState[]);

    const conditions = target.map((status) =>
        eq(metadataSyncStatus.syncStatus, status),
    );

    const rows = await db
        .select({ count: sql<number>`count(*)` })
        .from(metadataSyncStatus)
        .where(or(...conditions));

    return Number(rows[0]?.count ?? 0);
}

export async function markSyncPending(docId: string): Promise<void> {
    const now = nowIso();
    const existing = await getSyncStatusByDocId(docId);

    await db
        .insert(metadataSyncStatus)
        .values({
            docId,
            syncStatus: "pending",
            errorMessage: "",
            retryCount: existing?.retryCount ?? 0,
            lastAttemptedAt: null,
            lastSucceededAt: existing?.lastSucceededAt ?? null,
            createdAt: existing?.createdAt ?? now,
            updatedAt: now,
        })
        .onConflictDoUpdate({
            target: metadataSyncStatus.docId,
            set: {
                syncStatus: "pending",
                errorMessage: "",
                updatedAt: now,
            },
        });
}

export async function markSyncSuccess(docId: string): Promise<void> {
    const now = nowIso();
    const existing = await getSyncStatusByDocId(docId);

    await db
        .insert(metadataSyncStatus)
        .values({
            docId,
            syncStatus: "success",
            errorMessage: "",
            retryCount: existing?.retryCount ?? 0,
            lastAttemptedAt: now,
            lastSucceededAt: now,
            createdAt: existing?.createdAt ?? now,
            updatedAt: now,
        })
        .onConflictDoUpdate({
            target: metadataSyncStatus.docId,
            set: {
                syncStatus: "success",
                errorMessage: "",
                lastAttemptedAt: now,
                lastSucceededAt: now,
                updatedAt: now,
            },
        });
}

export async function markSyncFailed(
    docId: string,
    errorMessage: string,
): Promise<void> {
    const now = nowIso();
    const existing = await getSyncStatusByDocId(docId);

    await db
        .insert(metadataSyncStatus)
        .values({
            docId,
            syncStatus: "failed",
            errorMessage,
            retryCount: (existing?.retryCount ?? 0) + 1,
            lastAttemptedAt: now,
            lastSucceededAt: existing?.lastSucceededAt ?? null,
            createdAt: existing?.createdAt ?? now,
            updatedAt: now,
        })
        .onConflictDoUpdate({
            target: metadataSyncStatus.docId,
            set: {
                syncStatus: "failed",
                errorMessage,
                retryCount: (existing?.retryCount ?? 0) + 1,
                lastAttemptedAt: now,
                updatedAt: now,
            },
        });
}