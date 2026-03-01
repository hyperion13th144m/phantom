import { ApiResponse, ApiResponseError, ApiResponseSuccess, Hit, PatentDocumentSource } from "@/app/interfaces/search-results";
import { es } from "@/lib/es";
import { logger } from "@/lib/logger";
import type { estypes } from "@elastic/elasticsearch";
import { NextRequest, NextResponse } from "next/server";
export const runtime = "nodejs"; // @elastic/elasticsearch はnode runtime推奨

const INDEX = "patent-documents";


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
];


function toInt(v: string | null, def: number, min = 0, max = 1000) {
    const n = Number(v);
    if (!Number.isFinite(n)) return def;
    return Math.max(min, Math.min(max, Math.floor(n)));
}

export async function GET(req: NextRequest): Promise<NextResponse<ApiResponse>> {
    const { searchParams } = new URL(req.url);

    const q = (searchParams.get("q") ?? "").trim();
    const page = toInt(searchParams.get("page"), 1, 1, 100000);
    const size = toInt(searchParams.get("size"), 10, 1, 100);

    logger.info("Search request received", {
        query: q,
        page,
        size,
        url: req.url,
    });

    // 任意フィルタ（UI側で渡せるようにしておく）
    const applicant = (searchParams.get("applicant") ?? "").trim();
    const inventor = (searchParams.get("inventor") ?? "").trim();
    const assignee = (searchParams.get("assignee") ?? "").trim();
    const tag = (searchParams.get("tag") ?? "").trim();
    const documentName = (searchParams.get("documentName") ?? "").trim();
    const specialMentionMatterArticle = (searchParams.get("specialMentionMatterArticle") ?? "").trim();
    const rejectionReasonArticle = (searchParams.get("rejectionReasonArticle") ?? "").trim();
    const priorityClaims = (searchParams.get("priorityClaims") ?? "").trim();

    const from = (page - 1) * size;

    // q が空なら match_all（一覧用途）
    const mustQuery =
        q.length > 0
            ? [
                {
                    multi_match: {
                        query: q,
                        fields: SEARCH_FIELDS,
                        type: "best_fields" as const,
                        operator: "and" as const,
                    },
                },
            ]
            : [{ match_all: {} }];

    const sort = q.length > 0
        ? [{ _score: { order: "desc" as const } }]
        : [{ date: { order: "desc" as const } }];

    // フィルタ（mapping次第：keywordがあるなら `.keyword` を推奨）
    // ここでは “とりあえず text でも動く” ように match を使います。
    // もし `assignee.keyword`, `tags.keyword`, `applicants.keyword` があるなら term に変更してください。
    const filter: estypes.QueryDslQueryContainer[] = [];
    if (applicant) filter.push({ match: { applicants: applicant } });
    if (inventor) filter.push({ match: { inventors: inventor } });
    if (assignee) filter.push({ match: { assignees: assignee } });
    if (tag) filter.push({ match: { tags: tag } });
    if (documentName) filter.push({ match: { documentName: documentName } });
    if (specialMentionMatterArticle.length > 0) filter.push({ match: { specialMentionMatterArticle: specialMentionMatterArticle } });
    if (rejectionReasonArticle.length > 0) filter.push({ match: { rejectionReasonArticle: rejectionReasonArticle } });
    if (priorityClaims.length > 0) filter.push({ match: { priorityClaims: priorityClaims } });

    try {
        const result: estypes.SearchResponse<PatentDocumentSource> = await es.search({
            index: INDEX,
            from,
            size,
            track_total_hits: true,
            query: {
                bool: {
                    must: mustQuery,
                    //should: shouldQuery,
                    filter,
                },
            },
            highlight: {
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
            },
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
            _source: [
                "docId",
                "law",
                "applicationNumber",
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
                "images",
            ],
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
            });
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
