import type { QueryDslQueryContainer } from "@elastic/elasticsearch/lib/api/types";
import type { SearchAggregations, SearchResultItem } from "../types/metadata";
import { ES_INDEX, esClient } from "./client";

const AGG_SIZE = 200;

export async function searchDocuments(params: {
    q: string;
    page: number;
    size: number;
    applicants?: string[];
    inventors?: string[];
    law?: string[];
    documentName?: string[];
    tags?: string[];
    assignees?: string[];
}): Promise<{
    total: number;
    items: SearchResultItem[];
    aggregations: SearchAggregations;
}> {
    const from = (params.page - 1) * params.size;

    const filterClauses: QueryDslQueryContainer[] = [];
    if (params.applicants?.length) filterClauses.push({ terms: { applicants: params.applicants } });
    if (params.inventors?.length) filterClauses.push({ terms: { inventors: params.inventors } });
    if (params.law?.length) filterClauses.push({ terms: { law: params.law } });
    if (params.documentName?.length) filterClauses.push({ terms: { documentName: params.documentName } });
    if (params.tags?.length) filterClauses.push({ terms: { tags: params.tags } });
    if (params.assignees?.length) filterClauses.push({ terms: { assignees: params.assignees } });

    let query: QueryDslQueryContainer;
    if (filterClauses.length > 0) {
        query = {
            bool: {
                ...(params.q
                    ? {
                        must: [{
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
                        }],
                    }
                    : {}),
                filter: filterClauses,
            },
        };
    } else if (params.q) {
        query = {
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
        };
    } else {
        query = { match_all: {} };
    }

    const response = await esClient.search({
        index: ES_INDEX,
        from,
        size: params.size,
        query,
        sort: [{ _score: { order: "desc" } }],
        aggs: {
            applicants: { terms: { field: "applicants", size: AGG_SIZE } },
            inventors:  { terms: { field: "inventors",  size: AGG_SIZE } },
            law:        { terms: { field: "law",        size: AGG_SIZE } },
            documentName: { terms: { field: "documentName", size: AGG_SIZE } },
            tags:       { terms: { field: "tags",       size: AGG_SIZE } },
            assignees:  { terms: { field: "assignees",   size: AGG_SIZE } },
        },
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
            documentName:
                typeof source.documentName === "string" ? source.documentName : undefined,
        };
    });

    function extractBucketKeys(aggName: string): string[] {
        const agg = (response.aggregations as Record<string, unknown> | undefined)?.[aggName];
        if (!agg || typeof agg !== "object") return [];
        const buckets = (agg as { buckets?: Array<{ key: string }> }).buckets ?? [];
        return buckets.map((b) => b.key);
    }

    const aggregations: SearchAggregations = {
        applicants:   extractBucketKeys("applicants"),
        inventors:    extractBucketKeys("inventors"),
        law:          extractBucketKeys("law"),
        documentName: extractBucketKeys("documentName"),
        tags:         extractBucketKeys("tags"),
        assignees:    extractBucketKeys("assignees"),
    };

    return { total, items, aggregations };
}