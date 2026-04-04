import {
    countMetadataRecords,
    getMetadataByDocId,
    listMetadataPage,
} from "../db/metadataRepository";
import {
    createRestoreJob,
    finalizeRestoreJob,
    insertRestoreJobItems,
} from "../db/restoreJobRepository";
import {
    markSyncFailed,
    markSyncPending,
    markSyncSuccess,
} from "../db/syncStatusRepository";
import { bulkUpdateMetadataInElasticsearch } from "../es/bulkUpdate";
import type { MetadataRecord } from "../types/metadata";

export type RestoreResultItem = {
    docId: string;
    ok: boolean;
    error?: string;
};

function chunkArray<T>(items: T[], chunkSize: number): T[][] {
    const chunks: T[][] = [];
    for (let i = 0; i < items.length; i += chunkSize) {
        chunks.push(items.slice(i, i + chunkSize));
    }
    return chunks;
}

async function resolveRestoreTargets(params: {
    all?: boolean;
    docIds?: string[];
    limit?: number;
    offset?: number;
}): Promise<MetadataRecord[]> {
    if (params.docIds && params.docIds.length > 0) {
        const results: MetadataRecord[] = [];
        for (const docId of [...new Set(params.docIds)]) {
            const metadata = await getMetadataByDocId(docId);
            if (metadata) results.push(metadata);
        }
        return results;
    }

    if (params.all) {
        return listMetadataPage({
            limit: params.limit ?? 1000,
            offset: params.offset ?? 0,
        });
    }

    return [];
}

export async function restoreMetadataToElasticsearch(params: {
    all?: boolean;
    docIds?: string[];
    limit?: number;
    offset?: number;
    batchSize?: number;
}): Promise<{
    jobId: number;
    requested: number;
    succeeded: number;
    failed: number;
    totalAvailable?: number;
    results: RestoreResultItem[];
}> {
    const totalAvailable = params.all ? await countMetadataRecords() : undefined;

    const job = await createRestoreJob({
        targetMode: params.all ? "all" : "docIds",
        request: params,
        totalAvailable: totalAvailable ?? null,
    });

    const targets = await resolveRestoreTargets(params);
    const batchSize = Math.max(1, Math.min(params.batchSize ?? 200, 1000));
    const chunks = chunkArray(targets, batchSize);
    const results: RestoreResultItem[] = [];

    try {
        for (const chunk of chunks) {
            for (const metadata of chunk) {
                await markSyncPending(metadata.docId);
            }

            let bulkResults: Awaited<ReturnType<typeof bulkUpdateMetadataInElasticsearch>>;
            try {
                bulkResults = await bulkUpdateMetadataInElasticsearch(chunk);
            } catch (error) {
                const message =
                    error instanceof Error ? error.message : "Bulk Elasticsearch restore failed";

                const failedItems = [];
                for (const metadata of chunk) {
                    await markSyncFailed(metadata.docId, message);
                    const item = { docId: metadata.docId, ok: false, error: message };
                    results.push(item);
                    failedItems.push({
                        docId: metadata.docId,
                        ok: false,
                        errorMessage: message,
                    });
                }

                await insertRestoreJobItems({
                    jobId: job.id,
                    items: failedItems,
                });
                continue;
            }

            for (const bulkResult of bulkResults) {
                if (bulkResult.ok) {
                    await markSyncSuccess(bulkResult.docId);
                    results.push({ docId: bulkResult.docId, ok: true });
                } else {
                    await markSyncFailed(
                        bulkResult.docId,
                        bulkResult.error ?? "Unknown bulk restore error",
                    );
                    results.push({
                        docId: bulkResult.docId,
                        ok: false,
                        error: bulkResult.error ?? "Unknown bulk restore error",
                    });
                }
            }

            await insertRestoreJobItems({
                jobId: job.id,
                items: bulkResults.map((r) => ({
                    docId: r.docId,
                    ok: r.ok,
                    errorMessage: r.error ?? "",
                })),
            });
        }

        const succeeded = results.filter((r) => r.ok).length;
        const failed = results.length - succeeded;

        await finalizeRestoreJob({
            jobId: job.id,
            status: failed === 0 ? "completed" : succeeded > 0 ? "partial" : "failed",
            requestedCount: targets.length,
            succeededCount: succeeded,
            failedCount: failed,
        });

        return {
            jobId: job.id,
            requested: targets.length,
            succeeded,
            failed,
            totalAvailable,
            results,
        };
    } catch (error) {
        const succeeded = results.filter((r) => r.ok).length;
        const failed = results.length - succeeded;

        await finalizeRestoreJob({
            jobId: job.id,
            status: "failed",
            requestedCount: targets.length,
            succeededCount: succeeded,
            failedCount: failed,
        });

        throw error;
    }
}