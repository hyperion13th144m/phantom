import { getMetadataByDocId } from "../db/metadataRepository";
import {
    countBySyncStatuses,
    getDocIdsBySyncStatus,
    listUnsyncedStatuses,
    markSyncFailed,
    markSyncPending,
    markSyncSuccess,
} from "../db/syncStatusRepository";
import { bulkUpdateMetadataInElasticsearch } from "../es/bulkUpdate";
import type { MetadataRecord } from "../types/metadata";
import type { MetadataSyncState, MetadataSyncStatusRecord } from "../types/sync";

export type SyncResultItem = {
    docId: string;
    ok: boolean;
    error?: string;
};

async function resolveTargetDocIds(params: {
    docIds?: string[];
    allFailed?: boolean;
    allPending?: boolean;
    limit?: number;
}): Promise<string[]> {
    if (params.docIds && params.docIds.length > 0) {
        return [...new Set(params.docIds)];
    }

    const limit = params.limit ?? 1000;
    const collected: string[] = [];

    if (params.allFailed) {
        collected.push(...(await getDocIdsBySyncStatus("failed", limit)));
    }

    if (params.allPending) {
        const pendingIds = await getDocIdsBySyncStatus("pending", limit);
        for (const id of pendingIds) {
            if (!collected.includes(id)) collected.push(id);
        }
    }

    return collected;
}

function chunkArray<T>(items: T[], chunkSize: number): T[][] {
    const chunks: T[][] = [];
    for (let i = 0; i < items.length; i += chunkSize) {
        chunks.push(items.slice(i, i + chunkSize));
    }
    return chunks;
}

export async function resyncMetadataToElasticsearch(params: {
    docIds?: string[];
    allFailed?: boolean;
    allPending?: boolean;
    limit?: number;
    batchSize?: number;
}): Promise<{
    requested: number;
    succeeded: number;
    failed: number;
    results: SyncResultItem[];
}> {
    const targetDocIds = await resolveTargetDocIds(params);
    const results: SyncResultItem[] = [];
    const batchSize = Math.max(1, Math.min(params.batchSize ?? 200, 1000));

    const docIdChunks = chunkArray(targetDocIds, batchSize);

    for (const docIdChunk of docIdChunks) {
        const metadatas: MetadataRecord[] = [];

        for (const docId of docIdChunk) {
            try {
                const metadata = await getMetadataByDocId(docId);

                if (!metadata) {
                    results.push({
                        docId,
                        ok: false,
                        error: "Metadata not found in SQLite",
                    });
                    continue;
                }

                await markSyncPending(docId);
                metadatas.push(metadata);
            } catch (error) {
                results.push({
                    docId,
                    ok: false,
                    error: error instanceof Error ? error.message : "Unknown error",
                });
            }
        }

        if (metadatas.length === 0) {
            continue;
        }

        let bulkResults: Awaited<ReturnType<typeof bulkUpdateMetadataInElasticsearch>>;
        try {
            bulkResults = await bulkUpdateMetadataInElasticsearch(metadatas);
        } catch (error) {
            const message =
                error instanceof Error ? error.message : "Bulk Elasticsearch sync failed";

            for (const metadata of metadatas) {
                await markSyncFailed(metadata.docId, message);
                results.push({
                    docId: metadata.docId,
                    ok: false,
                    error: message,
                });
            }
            continue;
        }

        for (const bulkResult of bulkResults) {
            if (bulkResult.ok) {
                await markSyncSuccess(bulkResult.docId);
                results.push({
                    docId: bulkResult.docId,
                    ok: true,
                });
            } else {
                await markSyncFailed(
                    bulkResult.docId,
                    bulkResult.error ?? "Unknown bulk update error",
                );
                results.push({
                    docId: bulkResult.docId,
                    ok: false,
                    error: bulkResult.error ?? "Unknown bulk update error",
                });
            }
        }
    }

    const succeeded = results.filter((r) => r.ok).length;
    const failed = results.length - succeeded;

    return {
        requested: targetDocIds.length,
        succeeded,
        failed,
        results,
    };
}

export async function getUnsyncedStatusPage(params?: {
    statuses?: MetadataSyncState[];
    limit?: number;
    offset?: number;
}): Promise<{
    total: number;
    items: MetadataSyncStatusRecord[];
}> {
    const statuses = params?.statuses?.length
        ? params.statuses
        : (["pending", "failed"] as MetadataSyncState[]);
    const limit = params?.limit ?? 100;
    const offset = params?.offset ?? 0;

    const [total, items] = await Promise.all([
        countBySyncStatuses(statuses),
        listUnsyncedStatuses({ statuses, limit, offset }),
    ]);

    return { total, items };
}