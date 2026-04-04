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
import { updateMetadataInElasticsearch } from "../es/update";
import type { MetadataRecord, MetadataUpdateInput } from "../types/metadata";

export async function getMetadata(docId: string): Promise<MetadataRecord | null> {
    return await getMetadataByDocId(docId);
}

export async function saveMetadata(
    docId: string,
    input: MetadataUpdateInput,
): Promise<MetadataRecord> {
    const { before, after } = await upsertMetadata(docId, input);

    await insertMetadataHistory({
        docId,
        operation: before ? "update" : "create",
        before,
        after,
    });

    await markSyncPending(docId);

    try {
        await updateMetadataInElasticsearch(after);
        await markSyncSuccess(docId);
    } catch (error) {
        await markSyncFailed(
            docId,
            error instanceof Error ? error.message : "Unknown Elasticsearch sync error",
        );
    }

    return after;
}