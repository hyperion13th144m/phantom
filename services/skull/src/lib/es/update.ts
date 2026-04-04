import type { MetadataRecord } from "../types/metadata";
import { ES_INDEX, esClient } from "./client";

export async function updateMetadataInElasticsearch(
    metadata: MetadataRecord,
): Promise<void> {
    await esClient.update({
        index: ES_INDEX,
        id: metadata.docId,
        doc: {
            assignees: metadata.assignees,
            tags: metadata.tags,
            extraNumbers: metadata.extraNumbers,
            memo: metadata.memo,
            checked: metadata.checked,
        },
        doc_as_upsert: false,
    });
}