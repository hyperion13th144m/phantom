import { asc, desc, eq } from "drizzle-orm";
import type { RestoreJobItemRecord, RestoreJobRecord, RestoreJobStatus } from "../types/restore";
import { db } from "./client";
import { metadataRestoreJobItems, metadataRestoreJobs } from "./schema";

function nowIso(): string {
    return new Date().toISOString();
}

function toJobRecord(
    row: typeof metadataRestoreJobs.$inferSelect,
): RestoreJobRecord {
    return {
        id: row.id,
        jobType: row.jobType,
        targetMode: row.targetMode as "all" | "docIds",
        requestJson: row.requestJson,
        status: row.status as RestoreJobStatus,
        requestedCount: row.requestedCount,
        succeededCount: row.succeededCount,
        failedCount: row.failedCount,
        totalAvailable: row.totalAvailable ?? null,
        startedAt: row.startedAt,
        finishedAt: row.finishedAt ?? null,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
    };
}

function toJobItemRecord(
    row: typeof metadataRestoreJobItems.$inferSelect,
): RestoreJobItemRecord {
    return {
        id: row.id,
        jobId: row.jobId,
        docId: row.docId,
        ok: row.ok,
        errorMessage: row.errorMessage,
        createdAt: row.createdAt,
    };
}

export async function createRestoreJob(params: {
    targetMode: "all" | "docIds";
    request: unknown;
    totalAvailable?: number | null;
}): Promise<RestoreJobRecord> {
    const now = nowIso();

    const result = await db
        .insert(metadataRestoreJobs)
        .values({
            jobType: "restore",
            targetMode: params.targetMode,
            requestJson: JSON.stringify(params.request),
            status: "running",
            requestedCount: 0,
            succeededCount: 0,
            failedCount: 0,
            totalAvailable: params.totalAvailable ?? null,
            startedAt: now,
            finishedAt: null,
            createdAt: now,
            updatedAt: now,
        })
        .returning();

    return toJobRecord(result[0]);
}

export async function finalizeRestoreJob(params: {
    jobId: number;
    status: RestoreJobStatus;
    requestedCount: number;
    succeededCount: number;
    failedCount: number;
}): Promise<void> {
    const now = nowIso();

    await db
        .update(metadataRestoreJobs)
        .set({
            status: params.status,
            requestedCount: params.requestedCount,
            succeededCount: params.succeededCount,
            failedCount: params.failedCount,
            finishedAt: now,
            updatedAt: now,
        })
        .where(eq(metadataRestoreJobs.id, params.jobId));
}

export async function insertRestoreJobItems(params: {
    jobId: number;
    items: Array<{
        docId: string;
        ok: boolean;
        errorMessage?: string;
    }>;
}): Promise<void> {
    const now = nowIso();
    if (params.items.length === 0) return;

    await db.insert(metadataRestoreJobItems).values(
        params.items.map((item) => ({
            jobId: params.jobId,
            docId: item.docId,
            ok: item.ok,
            errorMessage: item.errorMessage ?? "",
            createdAt: now,
        })),
    );
}

export async function listRestoreJobs(params?: {
    limit?: number;
    offset?: number;
}): Promise<RestoreJobRecord[]> {
    const limit = params?.limit ?? 50;
    const offset = params?.offset ?? 0;

    const rows = await db
        .select()
        .from(metadataRestoreJobs)
        .orderBy(desc(metadataRestoreJobs.id))
        .limit(limit)
        .offset(offset);

    return rows.map(toJobRecord);
}

export async function getRestoreJobById(jobId: number): Promise<RestoreJobRecord | null> {
    const rows = await db
        .select()
        .from(metadataRestoreJobs)
        .where(eq(metadataRestoreJobs.id, jobId))
        .limit(1);

    if (rows.length === 0) return null;
    return toJobRecord(rows[0]);
}

export async function listRestoreJobItems(jobId: number, params?: {
    limit?: number;
    offset?: number;
}): Promise<RestoreJobItemRecord[]> {
    const limit = params?.limit ?? 200;
    const offset = params?.offset ?? 0;

    const rows = await db
        .select()
        .from(metadataRestoreJobItems)
        .where(eq(metadataRestoreJobItems.jobId, jobId))
        .orderBy(asc(metadataRestoreJobItems.id))
        .limit(limit)
        .offset(offset);

    return rows.map(toJobItemRecord);
}