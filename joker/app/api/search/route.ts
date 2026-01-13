import { getEnv } from "@/lib/env";
import { es } from "@/lib/es";
import { buildImageUrl } from "@/lib/helpers";
import type { estypes } from "@elastic/elasticsearch";
import { NextRequest, NextResponse } from "next/server";

export const runtime = "nodejs"; // @elastic/elasticsearch はnode runtime推奨

const INDEX = "patent-documents";

// 検索対象フィールド（指定どおり）
const SEARCH_FIELDS = [
    "inventionTitle.ngram^5",
    "independentClaims.ngram^10",
    "dependentClaims.ngram^8",
    "technicalField.ngram^2",
    "technicalField.ngram^2",
    "backgroundArt.ngram^2",
    "techProblem.ngram^2",
    "techSolution.ngram^2",
    "advantageousEffects.ngram^2",
    "industrialApplicability.ngram^2",
    "referenceToDepositedBiologicalMaterial.ngram^2",
    "lawOfIndustrialRegenerate.ngram^2",
    "descriptionOfEmbodiments.ngram^3",
    "abstract.ngram^5",
    "applicants.ngram^7",
    "inventors.ngram^6",
    "ocrText.ngram^1",
    "fileReferenceId^10",
    "fileReferenceId.ngram^10",
];

const SHOULD_SEARCH_FIELDS = [
    "inventionTitle^5",
    "independentClaims^10",
    "dependentClaims^8",
    "technicalField^2",
    "technicalField^2",
    "backgroundArt^2",
    "techProblem^2",
    "techSolution^2",
    "advantageousEffects^2",
    "industrialApplicability^2",
    "referenceToDepositedBiologicalMaterial^2",
    "lawOfIndustrialRegenerate^2",
    "descriptionOfEmbodiments^3",
    "abstract^5",
    "applicants.analyzed^7",
    "inventors.analyzed^6",
    "ocrText^1"
];

function toInt(v: string | null, def: number, min = 0, max = 1000) {
    const n = Number(v);
    if (!Number.isFinite(n)) return def;
    return Math.max(min, Math.min(max, Math.floor(n)));
}

export async function GET(req: NextRequest) {
    const { searchParams } = new URL(req.url);

    const q = (searchParams.get("q") ?? "").trim();
    const page = toInt(searchParams.get("page"), 1, 1, 100000);
    const size = toInt(searchParams.get("size"), 10, 1, 100);

    // 任意フィルタ（UI側で渡せるようにしておく）
    const applicant = (searchParams.get("applicant") ?? "").trim();
    const inventor = (searchParams.get("inventor") ?? "").trim();
    const assignee = (searchParams.get("assignee") ?? "").trim();
    const tag = (searchParams.get("tag") ?? "").trim();

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

    const shouldQuery =
        q.length > 0
            ? [
                {
                    multi_match: {
                        query: q,
                        fields: SHOULD_SEARCH_FIELDS,
                        type: "best_fields" as const,
                        operator: "and" as const,
                    },
                },
            ]
            : [{ match_all: {} }];

    const sort = q.length > 0
        ? [{ _score: { order: "desc" as const } }]
        : [{ submissionDate: { order: "desc" as const } }];

    // フィルタ（mapping次第：keywordがあるなら `.keyword` を推奨）
    // ここでは “とりあえず text でも動く” ように match を使います。
    // もし `assignee.keyword`, `tags.keyword`, `applicants.keyword` があるなら term に変更してください。
    const filter: estypes.QueryDslQueryContainer[] = [];
    if (applicant) filter.push({ match: { applicants: applicant } });
    if (inventor) filter.push({ match: { inventors: inventor } });
    if (assignee) filter.push({ match: { assignees: assignee } });
    if (tag) filter.push({ match: { tags: tag } });

    try {
        const result = await es.search({
            index: INDEX,
            from,
            size,
            track_total_hits: true,
            query: {
                bool: {
                    must: mustQuery,
                    should: shouldQuery,
                    filter,
                },
            },
            highlight: {
                pre_tags: ["<mark>"],
                post_tags: ["</mark>"],
                fields: {
                    inventionTitle: {},
                    independentClaims: {},
                    dependentClaims: {},
                    abstract: {},
                    descriptionOfEmbodiments: {},
                },
            },
            aggs: {
                applicants: {
                    terms: {
                        field: "applicants",
                        size: 50,
                    },
                },
                inventors: {
                    terms: {
                        field: "inventors",
                        size: 50,
                    },
                },
                assignees: {
                    terms: {
                        field: "assignees",
                        size: 50,
                    },
                },
                tags: {
                    terms: {
                        field: "tags",
                        size: 50,
                    },
                },
            },
            sort,
            _source: [
                "law",
                "applicationNumber",
                "submissionDate",
                "fileReferenceId",
                "inventionTitle",
                "independentClaims",
                "dependentClaims",
                "abstract",
                "applicants",
                "inventors",
                "assignees",
                "tags",
                "images",
            ],
        });

        const hits = (result.hits.hits ?? [])
            .map((h) => ({
                id: h._id,
                score: h._score ?? null,
                source: h._source ?? {},
                highlight: h.highlight ?? {},
            }))
            .map((h) => {
                // 画像URLを構築
                const images = (h.source as { images: Array<{ filename: string }> }).images.map((img) => ({
                    ...img,
                    filename: buildImageUrl(getEnv().IMAGE_BASE_URL, h.id ?? "", img.filename),
                })) ?? [];
                return {
                    ...h,
                    source: {
                        ...h.source,
                        images,
                        documentUrl: getEnv().DOCUMENT_BASE_URL + "/" + h.id,
                    },
                };
            });

        const total =
            typeof result.hits.total === "number"
                ? result.hits.total
                : result.hits.total?.value ?? 0;

        const aggregations = {
            applicants: (result.aggregations?.applicants as estypes.AggregationsStringTermsAggregate)?.buckets ?? [],
            inventors: (result.aggregations?.inventors as estypes.AggregationsStringTermsAggregate)?.buckets ?? [],
            assignees: (result.aggregations?.assignees as estypes.AggregationsStringTermsAggregate)?.buckets ?? [],
            tags: (result.aggregations?.tags as estypes.AggregationsStringTermsAggregate)?.buckets ?? [],
        };

        return NextResponse.json({
            page,
            size,
            total,
            hits,
            aggregations,
        });
    } catch (e: unknown) {
        // ESエラーの見える化
        return NextResponse.json(
            {
                error: "Elasticsearch search failed",
                message: (e as Error)?.message ?? String(e),
            },
            { status: 500 }
        );
    }
}
