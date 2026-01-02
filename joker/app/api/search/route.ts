import { es } from "@/lib/es";
import { NextRequest, NextResponse } from "next/server";

export const runtime = "nodejs"; // @elastic/elasticsearch はnode runtime推奨

const INDEX = "patent-documents";

// 検索対象フィールド（指定どおり）
const SEARCH_FIELDS = [
    "inventionTitle^4",
    "independentClaims^3",
    "dependentClaims^2",
    "embodiments",
    "abstract^2",
    "applicants^2",
    "assignee^2",
    "tags^2",
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
    const assignee = (searchParams.get("assignee") ?? "").trim(); // 完全一致に寄せるなら keyword が必要
    const tag = (searchParams.get("tag") ?? "").trim();
    const applicant = (searchParams.get("applicant") ?? "").trim();

    const from = (page - 1) * size;

    // q が空なら match_all（一覧用途）
    const mustQuery =
        q.length > 0
            ? [
                {
                    multi_match: {
                        query: q,
                        fields: SEARCH_FIELDS,
                        //type: "best_fields",
                        type: "phrase",
                        operator: "and",
                        //fuzziness: "AUTO",
                    },
                },
            ]
            : [{ match_all: {} }];

    // フィルタ（mapping次第：keywordがあるなら `.keyword` を推奨）
    // ここでは “とりあえず text でも動く” ように match を使います。
    // もし `assignee.keyword`, `tags.keyword`, `applicants.keyword` があるなら term に変更してください。
    const filter: any[] = [];
    if (assignee) filter.push({ match: { assignee } });
    if (tag) filter.push({ match: { tags: tag } });
    if (applicant) filter.push({ match: { applicants: applicant } });

    try {
        const result = await es.search({
            index: INDEX,
            from,
            size,
            track_total_hits: true,
            query: {
                bool: {
                    must: mustQuery,
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
                    embodiments: {},
                    abstract: {},
                    applicants: {},
                    assignee: {},
                    tags: {},
                },
            },
            // ソートは必要なら追加
            // sort: [{ _score: "desc" }, { _id: "asc" }],
            _source: [
                "inventionTitle",
                "independentClaims",
                "dependentClaims",
                "embodiments",
                "abstract",
                "applicants",
                "assignee",
                "tags",
            ],
        });

        const hits = (result.hits.hits ?? []).map((h) => ({
            id: h._id,
            score: h._score ?? null,
            source: h._source ?? {},
            highlight: (h as any).highlight ?? {},
        }));

        const total =
            typeof result.hits.total === "number"
                ? result.hits.total
                : result.hits.total?.value ?? 0;

        return NextResponse.json({
            page,
            size,
            total,
            hits,
        });
    } catch (e: any) {
        // ESエラーの見える化
        return NextResponse.json(
            {
                error: "Elasticsearch search failed",
                message: e?.message ?? String(e),
            },
            { status: 500 }
        );
    }
}
