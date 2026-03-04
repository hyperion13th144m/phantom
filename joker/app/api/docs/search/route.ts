import { es, ES_INDEX } from "@/lib/es";
import { NextResponse } from "next/server";
import { z } from "zod";

export const runtime = "nodejs";

const QuerySchema = z.object({
    q: z.string().optional(), // 全文検索クエリ
    page: z.coerce.number().int().min(1).default(1),
    size: z.coerce.number().int().min(1).max(100).default(25),
});

export async function GET(req: Request) {
    const url = new URL(req.url);
    const parsed = QuerySchema.safeParse({
        q: url.searchParams.get("q") ?? undefined,
        page: url.searchParams.get("page") ?? undefined,
        size: url.searchParams.get("size") ?? undefined,
    });
    if (!parsed.success) {
        return NextResponse.json({ error: parsed.error.flatten() }, { status: 400 });
    }

    const { q, page, size } = parsed.data;
    const from = (page - 1) * size;

    // ここはあなたの index のフィールドに合わせて調整してOK
    // 例：inventionTitle, applicants, applicationNumber など
    const sourceFields = [
        "law",
        "inventionTitle",
        "applicants",
        "inventors",
        "applicationNumber",
        "internationalNumber",
        "fileReferenceId",
        "documentName",
    ];

    const body =
        q && q.trim()
            ? {
                from,
                size,
                track_total_hits: true,
                query: {
                    bool: {
                        should: [
                            {
                                match_phrase: {
                                    "inventionTitle.ngram^3": q.trim()
                                }
                            },
                            {
                                match_phrase: {
                                    "independentClaims.ngram": q.trim()
                                }
                            },
                            {
                                match_phrase: {
                                    "dependentClaims.ngram": q.trim()
                                }
                            },
                            {
                                match_phrase: {
                                    "abstract.ngram": q.trim()
                                }
                            },
                            {
                                match_phrase: {
                                    "applicants.ngram": q.trim()
                                }
                            },
                            {
                                match_phrase: {
                                    "inventors.ngram": q.trim()
                                }
                            },
                            {
                                match: {
                                    assignees: {
                                        query: q.trim()
                                    }
                                }
                            },
                            {
                                match: {
                                    tags: {
                                        query: q.trim()
                                    }
                                }
                            },
                            {
                                match: {
                                    extraNumbers: {
                                        query: q.trim()
                                    }
                                }
                            }
                        ]
                        //query: q.trim(),
                        //// あなたの全文検索対象に合わせる（例）
                        //fields: [
                        //    "dependentClaims.ngram",
                        //    "embodiments.ngram",
                        //    "abstract.ngram",
                        //    "applicants.ngram",
                        //    "inventors.ngram",
                        //    "assignees",
                        //    "tags",
                        //    "extraNumbers",
                        //],
                    },
                },
                _source: sourceFields,
            }
            : {
                from,
                size,
                track_total_hits: true,
                query: { match_all: {} },
                sort: [{ _doc: "asc" }],
                _source: sourceFields,
            };

    const resp = await es.search({
        index: ES_INDEX,
        ...body,
    });

    const total =
        typeof resp.hits.total === "number"
            ? resp.hits.total
            : resp.hits.total?.value ?? 0;

    const rows = resp.hits.hits.map((h: any) => ({
        docId: h._id as string,
        // 表示用
        inventionTitle: h._source?.inventionTitle ?? "",
        applicants: h._source?.applicants ?? "",
        inventors: h._source?.inventors ?? "",
        applicationNumber: h._source?.applicationNumber ?? "",
        fileReferenceId: h._source?.fileReferenceId ?? "",
        documentName: h._source?.documentName ?? "",
        internationalNumber: h._source?.internationalNumber ?? "",
        law: h._source?.law ?? "",
    }));
    console.log(`ES search: q=${q} total=${total} returned=${rows.length}`);
    console.log(`ES search body: ${JSON.stringify(rows)}`);

    return NextResponse.json({ page, size, total, rows });
}