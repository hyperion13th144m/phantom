import { getMetadataByDocId } from "../db/metadataRepository";
import { getSyncStatusByDocId } from "../db/syncStatusRepository";
import { getDocumentById } from "../es/document";
import type { DocumentWithMetadata } from "../types/document";

export async function getDocumentWithMetadata(
    docId: string,
): Promise<DocumentWithMetadata> {
    const [document, metadata, syncStatus] = await Promise.all([
        getDocumentById(docId),
        getMetadataByDocId(docId),
        getSyncStatusByDocId(docId),
    ]);

    return {
        document,
        metadata: metadata
            ? {
                docId: metadata.docId,
                assignees: metadata.assignees,
                tags: metadata.tags,
                extraNumbers: metadata.extraNumbers,
                memo: metadata.memo,
                checked: metadata.checked,
                createdAt: metadata.createdAt,
                updatedAt: metadata.updatedAt,
            }
            : {
                docId,
                assignees: [],
                tags: [],
                extraNumbers: [],
                memo: "",
                checked: false,
                createdAt: null,
                updatedAt: null,
            },
        syncStatus: syncStatus ?? null,
    };
}