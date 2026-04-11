import { getMetadataByDocIds } from "../db/metadataRepository";
import { getSyncStatusesByDocIds } from "../db/syncStatusRepository";
import { searchDocuments } from "../es/search";
import type { SearchResponse } from "../types/metadata";

export async function searchDocumentsWithMetadata(params: {
    q: string;
    page: number;
    size: number;
    applicants?: string[];
    inventors?: string[];
    law?: string[];
    documentName?: string[];
    tags?: string[];
    assignees?: string[];
}): Promise<SearchResponse> {
    const result = await searchDocuments(params);
    const docIds = result.items.map((item) => item.docId);

    const [metadataMap, syncStatusMap] = await Promise.all([
        getMetadataByDocIds(docIds),
        getSyncStatusesByDocIds(docIds),
    ]);

    const items = result.items.map((item) => ({
        ...item,
        metadata: metadataMap.get(item.docId) ?? null,
        syncStatus: syncStatusMap.get(item.docId) ?? null,
    }));

    return {
        page: params.page,
        size: params.size,
        total: result.total,
        items,
        aggregations: result.aggregations,
    };
}