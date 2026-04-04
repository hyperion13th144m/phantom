import {
    getMetadataByDocId,
    insertMetadataHistory,
    upsertMetadata,
} from "../db/metadataRepository";
import {
    markSyncFailed,
    markSyncPending,
    markSyncSuccess,
} from "../db/syncStatusRepository";
import { bulkUpdateMetadataInElasticsearch } from "../es/bulkUpdate";
import type { MetadataRecord } from "../types/metadata";

export type BulkPatch = {
    tagsToAdd?: string[];
    assigneesToAdd?: string[];
    extraNumbersToAdd?: string[];
    checked?: boolean;
    memoAppend?: string;
};

export type BulkUpdateResultItem = {
    docId: string;
    ok: boolean;
    error?: string;
};

function uniq(values: string[]): string[] {
    return [...new Set(values.map((v) => v.trim()).filter(Boolean))];
}

function mergeTextArray(base: string[], add?: string[]): string[] {
    return uniq([...(base ?? []), ...(add ?? [])]);
}

function mergeMemo(base: string, append?: string): string {
    const normalizedAppend = (append ?? "").trim();
    if (!normalizedAppend) return base ?? "";
    if (!base?.trim()) return normalizedAppend;
    return `${base}\n${normalizedAppend}`;
}

export async function bulkUpdateMetadata(params: {
    docIds: string[];
    patch: BulkPatch;
}): Promise<{
    requested: number;
    succeeded: number;
    failed: number;
    results: BulkUpdateResultItem[];
}> {
    const results: BulkUpdateResultItem[] = [];
    const pendingEsUpdates: MetadataRecord[] = [];
    const prefailedDocIds = new Set<string>();

    for (const docId of params.docIds) {
        try {
            const existing = await getMetadataByDocId(docId);

            const nextInput = {
                assignees: mergeTextArray(
                    existing?.assignees ?? [],
                    params.patch.assigneesToAdd,
                ),
                tags: mergeTextArray(existing?.tags ?? [], params.patch.tagsToAdd),
                extraNumbers: mergeTextArray(
                    existing?.extraNumbers ?? [],
                    params.patch.extraNumbersToAdd,
                ),
                memo: mergeMemo(existing?.memo ?? "", params.patch.memoAppend),
                checked:
                    typeof params.patch.checked === "boolean"
                        ? params.patch.checked
                        : (existing?.checked ?? false),
            };

            const { before, after } = await upsertMetadata(docId, nextInput);

            await insertMetadataHistory({
                docId,
                operation: "bulk_update",
                before,
                after,
            });

            await markSyncPending(docId);
            pendingEsUpdates.push(after);
        } catch (error) {
            prefailedDocIds.add(docId);
            results.push({
                docId,
                ok: false,
                error: error instanceof Error ? error.message : "Unknown error",
            });
        }
    }

    if (pendingEsUpdates.length > 0) {
        try {
            const bulkResults = await bulkUpdateMetadataInElasticsearch(pendingEsUpdates);

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
        } catch (error) {
            const message =
                error instanceof Error ? error.message : "Bulk Elasticsearch sync failed";

            for (const metadata of pendingEsUpdates) {
                await markSyncFailed(metadata.docId, message);

                if (!prefailedDocIds.has(metadata.docId)) {
                    results.push({
                        docId: metadata.docId,
                        ok: false,
                        error: message,
                    });
                }
            }
        }
    }

    const succeeded = results.filter((r) => r.ok).length;
    const failed = results.length - succeeded;

    return {
        requested: params.docIds.length,
        succeeded,
        failed,
        results,
    };
}