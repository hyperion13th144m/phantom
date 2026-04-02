import { ApiResponseError, ApiResponseSuccess, Hit, PatentDocumentSource } from "@/app/interfaces/search-results";
import { es } from "@/lib/es";
import { logger } from "@/lib/logger";
import type { estypes } from "@elastic/elasticsearch";
import { NextRequest, NextResponse } from "next/server";
import { z } from "zod";

export const runtime = "nodejs"; // @elastic/elasticsearch はnode runtime推奨

const INDEX = "patent-documents";


const QuerySchema = z.object({
    q: z.string().optional(), // 全文検索クエリ
    page: z.coerce.number().int().min(1).default(1),
    size: z.coerce.number().int().min(1).max(100).default(25),
    applicant: z.string().optional(),
    inventor: z.string().optional(),
    assignee: z.string().optional(),
    tag: z.string().optional(),
    documentName: z.string().optional(),
    specialMentionMatterArticle: z.string().optional(),
    rejectionReasonArticle: z.string().optional(),
    priorityClaims: z.string().optional(),
    withHighlight: z.boolean().optional(),
});

// 検索対象フィールド（指定どおり）
const SEARCH_FIELDS = [
    "independentClaims.ngram^10",
    "dependentClaims.ngram^8",
    "abstract.ngram^5",
    "embodiments.ngram^3",
    "opinionContentsArticle.ngram^3",
    "inventionTitle.ngram^2",
    "technicalField.ngram^2",
    "backgroundArt.ngram^2",
    "techProblem.ngram^2",
    "techSolution.ngram^2",
    "advantageousEffects.ngram^2",
    "industrialApplicability.ngram^2",
    "referenceToDepositedBiologicalMaterial.ngram^2",
    "lawOfIndustrialRegenerate.ngram^2",
    "draftingBody.ngram^2",
    "conclusionPartArticle.ngram^2",
    "contentsOfAmendment.ngram^2",
    "ocrText.ngram^1",
    "applicationNumber.ngram^5",
    "internationalNumber.ngram^5",
    "fileReferenceId.ngram^5",
    "extraNumbers.ngram^5",
];

const sourceFields = [
    "docId",
    "law",
    "applicationNumber",
    "internationalNumber",
    "documentCode",
    "documentName",
    "date",
    "fileReferenceId",
    "inventionTitle",
    "independentClaims",
    "dependentClaims",
    "abstract",
    "applicants",
    "inventors",
    "assignees",
    "tags",
    "specialMentionMatterArticle",
    "rejectionReasonArticle",
    "extraNumbers"
];

function toInt(v: string | null, def: number, min = 0, max = 1000) {
    const n = Number(v);
    if (!Number.isFinite(n)) return def;
    return Math.max(min, Math.min(max, Math.floor(n)));
}

export async function GET(req: NextRequest) {
    const url = new URL(req.url);

    const parsed = QuerySchema.safeParse({
        q: url.searchParams.get("q") ?? undefined,
        page: url.searchParams.get("page") ?? undefined,
        size: url.searchParams.get("size") ?? undefined,
        applicant: url.searchParams.get("applicant") ?? undefined,
        inventor: url.searchParams.get("inventor") ?? undefined,
        assignee: url.searchParams.get("assignee") ?? undefined,
        tag: url.searchParams.get("tag") ?? undefined,
        documentName: url.searchParams.get("documentName") ?? undefined,
        specialMentionMatterArticle: url.searchParams.get("specialMentionMatterArticle") ?? undefined,
        rejectionReasonArticle: url.searchParams.get("rejectionReasonArticle") ?? undefined,
        priorityClaims: url.searchParams.get("priorityClaims") ?? undefined,
        withHighlight: url.searchParams.get("withHighlight") === "true" ? true : undefined,
    });
    if (!parsed.success) {
        return NextResponse.json({ error: parsed.error.flatten() }, { status: 400 });
    }

    const {
        q,
        page,
        size,
        applicant,
        inventor,
        assignee,
        tag,
        documentName,
        specialMentionMatterArticle,
        rejectionReasonArticle,
        priorityClaims,
        withHighlight,
    } = parsed.data;
    const from = (page - 1) * size;

    logger.info("Search request received", {
        query: q,
        page,
        size,
        url: req.url,
    });

    const sort = (q && q.length > 0)
        ? [{ _score: { order: "desc" as const } }]
        : [{ date: { order: "desc" as const } }];

    const filter: estypes.QueryDslQueryContainer[] = [];
    if (applicant) filter.push({ match: { applicants: applicant } });
    if (inventor) filter.push({ match: { inventors: inventor } });
    if (assignee) filter.push({ match: { assignees: assignee } });
    if (tag) filter.push({ match: { tags: tag } });
    if (documentName) filter.push({ match: { documentName: documentName } });
    if (specialMentionMatterArticle) filter.push({ match: { specialMentionMatterArticle: specialMentionMatterArticle } });
    if (rejectionReasonArticle) filter.push({ match: { rejectionReasonArticle: rejectionReasonArticle } });
    if (priorityClaims) filter.push({ match: { priorityClaims: priorityClaims } });

    const query = (q && q.trim().length > 0)
        ? {
            bool: {
                must: [
                    {
                        multi_match: {
                            query: q.trim(),
                            fields: SEARCH_FIELDS,
                            type: "best_fields" as const,
                            operator: "and" as const,
                        }
                    }
                ],
                filter,
            }
        }
        : {
            bool: {
                must: [{ match_all: {} }],
                filter,
            },
        };

    const highlight = withHighlight ? {
        pre_tags: ["<mark>"],
        post_tags: ["</mark>"],
        require_field_match: false,
        fragment_size: 150,
        number_of_fragments: 3,
        fields: {
            independentClaims: {
                fragment_size: 150,
                number_of_fragments: 2,
            },
            dependentClaims: {
                fragment_size: 150,
                number_of_fragments: 2,
            },
            abstract: {
                fragment_size: 150,
                number_of_fragments: 1,
            },
            opinionContentsArticle: {
                fragment_size: 150,
                number_of_fragments: 2,
            },
            draftingBody: {
                fragment_size: 150,
                number_of_fragments: 2,
            },
            ocrText: {
                fragment_size: 150,
                number_of_fragments: 2,
            },
        },
    }
        : undefined;

    try {
        const result: estypes.SearchResponse<PatentDocumentSource> = await es.search({
            index: INDEX,
            from,
            size,
            track_total_hits: true,
            query,
            highlight: highlight,
            aggs: {
                applicants: {
                    terms: {
                        field: "applicants",
                        size: 20,
                    },
                },
                inventors: {
                    terms: {
                        field: "inventors",
                        size: 20,
                    },
                },
                assignees: {
                    terms: {
                        field: "assignees",
                        size: 20,
                    },
                },
                tags: {
                    terms: {
                        field: "tags",
                        size: 20,
                    },
                },
                documentNames: {
                    terms: {
                        field: "documentName",
                        size: 20,
                    },
                },
                specialMentionMatterArticle: {
                    terms: {
                        field: "specialMentionMatterArticle",
                        size: 20,
                    },
                },
                rejectionReasonArticle: {
                    terms: {
                        field: "rejectionReasonArticle",
                        size: 20,
                    },
                },
                priorityClaims: {
                    terms: {
                        field: "priorityClaims",
                        size: 10,
                    },
                }
            },
            sort,
            _source: sourceFields,
        });

        const hits: Hit[] = (result.hits.hits ?? [])
            .map((h) => {
                if (process.env.NODE_ENV !== "production" && h.highlight) {
                    logger.info("Highlight found", {
                        id: h._id,
                        highlightKeys: Object.keys(h.highlight),
                        highlightSample: Object.fromEntries(
                            Object.entries(h.highlight).slice(0, 2).map(([k, v]) => [k, v])
                        ),
                    });
                }
                return {
                    id: h._id,
                    score: h._score,
                    source: h._source as Partial<PatentDocumentSource>,
                    highlight: h.highlight ?? {},
                };
            })
            .filter(h => h.id !== undefined && h.source !== undefined) as Hit[];
        const total =
            typeof result.hits.total === "number"
                ? result.hits.total
                : result.hits.total?.value ?? 0;

        const aggregations = {
            applicants: result.aggregations && Array.isArray((result.aggregations.applicants as estypes.AggregationsStringTermsAggregate)?.buckets)
                ? (result.aggregations.applicants as estypes.AggregationsStringTermsAggregate).buckets as Array<{ key: string; doc_count: number }>
                : [],
            inventors: result.aggregations && Array.isArray((result.aggregations.inventors as estypes.AggregationsStringTermsAggregate)?.buckets)
                ? (result.aggregations.inventors as estypes.AggregationsStringTermsAggregate).buckets as Array<{ key: string; doc_count: number }>
                : [],
            assignees: result.aggregations && Array.isArray((result.aggregations.assignees as estypes.AggregationsStringTermsAggregate)?.buckets)
                ? (result.aggregations.assignees as estypes.AggregationsStringTermsAggregate).buckets as Array<{ key: string; doc_count: number }>
                : [],
            tags: result.aggregations && Array.isArray((result.aggregations.tags as estypes.AggregationsStringTermsAggregate)?.buckets)
                ? (result.aggregations.tags as estypes.AggregationsStringTermsAggregate).buckets as Array<{ key: string; doc_count: number }>
                : [],
            documentNames: result.aggregations && Array.isArray((result.aggregations.documentNames as estypes.AggregationsStringTermsAggregate)?.buckets)
                ? (result.aggregations.documentNames as estypes.AggregationsStringTermsAggregate).buckets as Array<{ key: string; doc_count: number }>
                : [],
            specialMentionMatterArticle: result.aggregations && Array.isArray((result.aggregations.specialMentionMatterArticle as estypes.AggregationsStringTermsAggregate)?.buckets)
                ? (result.aggregations.specialMentionMatterArticle as estypes.AggregationsStringTermsAggregate).buckets as Array<{ key: string; doc_count: number }>
                : [],
            rejectionReasonArticle: result.aggregations && Array.isArray((result.aggregations.rejectionReasonArticle as estypes.AggregationsStringTermsAggregate)?.buckets)
                ? (result.aggregations.rejectionReasonArticle as estypes.AggregationsStringTermsAggregate).buckets as Array<{ key: string; doc_count: number }>
                : [],
            priorityClaims: result.aggregations && Array.isArray((result.aggregations.priorityClaims as estypes.AggregationsStringTermsAggregate)?.buckets)
                ? (result.aggregations.priorityClaims as estypes.AggregationsStringTermsAggregate).buckets as Array<{ key: string; doc_count: number }>
                : [],
        };

        logger.info("Search completed successfully", {
            query: q,
            total,
            resultsCount: hits.length,
            page,
        });

        return NextResponse.json({
            page,
            size,
            total,
            hits,
            aggregations,
        } as ApiResponseSuccess);
    } catch (e: unknown) {
        // ESエラーの見える化
        logger.error("Elasticsearch search failed", {
            query: q,
            error: (e as Error)?.message ?? String(e),
            stack: (e as Error)?.stack,
        });

        return NextResponse.json(
            {
                error: "Elasticsearch search failed",
                message: (e as Error)?.message ?? String(e),
            } as ApiResponseError,
            { status: 500 }
        );
    }
}
