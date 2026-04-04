import type { SearchResultItem } from "../types/metadata";
import { ES_INDEX, esClient } from "./client";

export async function searchDocuments(params: {
    q: string;
    page: number;
    size: number;
}): Promise<{
    total: number;
    items: SearchResultItem[];
}> {
    const from = (params.page - 1) * params.size;

    const response = await esClient.search({
        index: ES_INDEX,
        from,
        size: params.size,
        query: params.q
            ? {
                multi_match: {
                    query: params.q,
                    fields: [
                        "inventionTitle^3",
                        "abstract^2",
                        "independentClaims",
                        "dependentClaims",
                        "embodiments",
                        "applicants",
                        "assignee",
                        "tags",
                    ],
                },
            }
            : {
                match_all: {},
            },
        sort: [{ _score: { order: "desc" } }],
    });

    const total =
        typeof response.hits.total === "number"
            ? response.hits.total
            : (response.hits.total?.value ?? 0);

    const items: SearchResultItem[] = response.hits.hits.map((hit) => {
        const source = (hit._source ?? {}) as Record<string, unknown>;

        return {
            docId: String(hit._id),
            inventionTitle:
                typeof source.inventionTitle === "string"
                    ? source.inventionTitle
                    : undefined,
            applicants: Array.isArray(source.applicants)
                ? source.applicants.filter((v): v is string => typeof v === "string")
                : undefined,
            assignee:
                typeof source.assignee === "string" ? source.assignee : null,
            tags: Array.isArray(source.tags)
                ? source.tags.filter((v): v is string => typeof v === "string")
                : undefined,
            abstract:
                typeof source.abstract === "string" ? source.abstract : undefined,
        };
    });

    return { total, items };
}