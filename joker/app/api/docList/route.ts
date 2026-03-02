import { es } from "@/lib/es";
import { logger } from "@/lib/logger";
import { NextRequest, NextResponse } from "next/server";

export const runtime = "nodejs";

const INDEX = "patent-documents";

interface DocResult {
    docId: string;
    applicants: string[];
    fileReferenceId: string;
    date: string;
    documentName: string;
    documentCode: string;
    extraNumbers?: string[];
}

interface GroupResult {
    law: string;
    applicationNumber: string;
    docs: DocResult[];
}

export async function GET(req: NextRequest) {
    const { searchParams } = new URL(req.url);

    // 検索キーワード
    const applicantKeyword = (searchParams.get("applicants") ?? "").trim();
    const inventorKeyword = (searchParams.get("inventors") ?? "").trim();
    const applicationNumberKeyword = (searchParams.get("applicationNumber") ?? "").trim();
    const fileReferenceIdKeyword = (searchParams.get("fileReferenceId") ?? "").trim();
    const law = (searchParams.get("law") ?? "").trim();

    logger.info("DocList search request received", {
        applicants: applicantKeyword,
        inventors: inventorKeyword,
        applicationNumber: applicationNumberKeyword,
        fileReferenceId: fileReferenceIdKeyword,
        law,
        url: req.url,
    });

    if (!applicantKeyword && !inventorKeyword && !applicationNumberKeyword && !fileReferenceIdKeyword && !law) {
        return NextResponse.json(
            {
                error: "Bad Request",
                message: "At least one of applicants, inventors, applicationNumber, fileReferenceId, or law parameter is required",
            },
            { status: 400 }
        );
    }

    try {
        // クエリ条件の構築（AND条件）
        const mustQueries: any[] = [];

        if (inventorKeyword) {
            mustQueries.push({
                bool: {
                    should: [
                        {
                            match: {
                                "inventors.ngram": {
                                    query: inventorKeyword,
                                    operator: "or",
                                },
                            },
                        },
                        {
                            match: {
                                inventors: {
                                    query: inventorKeyword,
                                    fuzziness: "AUTO",
                                    operator: "or",
                                },
                            },
                        },
                    ],
                    minimum_should_match: 1,
                },
            });
        }

        if (applicantKeyword) {
            mustQueries.push({
                bool: {
                    should: [
                        {
                            match: {
                                "applicants.ngram": {
                                    query: applicantKeyword,
                                    operator: "or",
                                },
                            },
                        },
                        {
                            match: {
                                applicants: {
                                    query: applicantKeyword,
                                    fuzziness: "AUTO",
                                    operator: "or",
                                },
                            },
                        },
                    ],
                    minimum_should_match: 1,
                },
            });
        }

        if (applicationNumberKeyword) {
            mustQueries.push({
                match_phrase: {
                    "applicationNumber.ngram": applicationNumberKeyword,
                },
            });
        }

        if (fileReferenceIdKeyword) {
            mustQueries.push({
                bool: {
                    should: [
                        {
                            match_phrase: {
                                "fileReferenceId.ngram": fileReferenceIdKeyword,
                            },
                        },
                        {
                            match_phrase: {
                                "extraNumbers.ngram": fileReferenceIdKeyword,
                            },
                        }
                    ],
                    minimum_should_match: 1,
                },
            });
        }

        if (law) {
            mustQueries.push({
                match: {
                    law: {
                        query: law,
                        fuzziness: "AUTO",
                        operator: "and",
                    },
                },
            });
        }

        // 全ドキュメントを取得するための大きなサイズを設定
        const result = await es.search({
            index: INDEX,
            size: 10000,
            track_total_hits: true,
            query: {
                bool: {
                    must: mustQueries.length > 0 ? mustQueries : [{ match_all: {} }],
                },
            },
            sort: [
                { applicationNumber: "desc" },
            ],
            _source: [
                "docId",
                "law",
                "applicationNumber",
                "applicants",
                "fileReferenceId",
                "date",
                "documentName",
                "documentCode",
                "extraNumbers"
            ],
        });

        const hits = result.hits.hits ?? [];

        // law と applicationNumber でグループ化
        const groupMap = new Map<string, GroupResult>();
        const groupKeySet = new Set<string>();

        hits.forEach((hit) => {
            const source = hit._source as any;
            const resultLaw = source.law || "";
            const resultApplicationNumber = source.applicationNumber || "";
            const groupKey = `${resultLaw}|${resultApplicationNumber}`;

            const doc: DocResult = {
                docId: source.docId || hit._id || "",
                applicants: Array.isArray(source.applicants)
                    ? source.applicants
                    : source.applicants
                        ? [source.applicants]
                        : [],
                fileReferenceId: source.fileReferenceId || "",
                date: source.date || "",
                documentName: source.documentName || "",
                documentCode: source.documentCode || "",
                extraNumbers: Array.isArray(source.extraNumbers)
                    ? source.extraNumbers
                    : source.extraNumbers
                        ? [source.extraNumbers]
                        : [],
            };

            if (!groupMap.has(groupKey)) {
                groupMap.set(groupKey, {
                    law: resultLaw,
                    applicationNumber: resultApplicationNumber,
                    docs: [],
                });
                groupKeySet.add(groupKey);
            }

            groupMap.get(groupKey)!.docs.push(doc);
        });

        // グループを配列に変換し、順序を保証
        const results: GroupResult[] = Array.from(groupKeySet).map((key) =>
            groupMap.get(key)!
        );

        logger.info("DocList search completed successfully", {
            applicants: applicantKeyword,
            inventors: inventorKeyword,
            applicationNumber: applicationNumberKeyword,
            fileReferenceId: fileReferenceIdKeyword,
            law,
            totalHits: hits.length,
            groupCount: results.length,
        });

        return NextResponse.json(results);
    } catch (e: unknown) {
        logger.error("Elasticsearch docList search failed", {
            applicants: applicantKeyword,
            inventors: inventorKeyword,
            applicationNumber: applicationNumberKeyword,
            fileReferenceId: fileReferenceIdKeyword,
            law,
            error: (e as Error)?.message ?? String(e),
            stack: (e as Error)?.stack,
        });

        return NextResponse.json(
            {
                error: "Elasticsearch search failed",
                message: (e as Error)?.message ?? String(e),
            },
            { status: 500 }
        );
    }
}
