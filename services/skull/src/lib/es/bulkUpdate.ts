import type { MetadataRecord } from "../types/metadata";
import { ES_INDEX, esClient } from "./client";

export type BulkElasticsearchUpdateItemResult = {
    docId: string;
    ok: boolean;
    error?: string;
};

function buildMetadataDoc(metadata: MetadataRecord) {
    return {
        assignees: metadata.assignees,
        tags: metadata.tags,
        extraNumbers: metadata.extraNumbers,
        memo: metadata.memo,
        checked: metadata.checked,
    };
}

export async function bulkUpdateMetadataInElasticsearch(
    items: MetadataRecord[],
): Promise<BulkElasticsearchUpdateItemResult[]> {
    if (items.length === 0) {
        return [];
    }

    const operations = items.flatMap((metadata) => [
        {
            update: {
                _index: ES_INDEX,
                _id: metadata.docId,
            },
        },
        {
            doc: buildMetadataDoc(metadata),
            doc_as_upsert: false,
        },
    ]);

    const response = await esClient.bulk({
        refresh: false,
        operations,
    });

    const results: BulkElasticsearchUpdateItemResult[] = [];
    const responseItems = response.items ?? [];

    for (let i = 0; i < items.length; i += 1) {
        const sourceItem = items[i];
        const bulkItem = responseItems[i];
        const updateResult = bulkItem?.update;

        if (!updateResult) {
            results.push({
                docId: sourceItem.docId,
                ok: false,
                error: "Missing bulk update result",
            });
            continue;
        }

        if (updateResult.error) {
            const error =
                typeof updateResult.error === "string"
                    ? updateResult.error
                    : JSON.stringify(updateResult.error);

            results.push({
                docId: sourceItem.docId,
                ok: false,
                error,
            });
            continue;
        }

        const status = updateResult.status ?? 500;
        if (status >= 200 && status < 300) {
            results.push({
                docId: sourceItem.docId,
                ok: true,
            });
        } else {
            results.push({
                docId: sourceItem.docId,
                ok: false,
                error: `Unexpected status: ${status}`,
            });
        }
    }

    return results;
}