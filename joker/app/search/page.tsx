"use client";

import { Suspense, useCallback, useEffect, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import ErrorMessage from "@/app/components/error-message";
import HitResults from "@/app/components/hit-results";
import Pagination from "@/app/components/pagination";
import SimpleInput from "@/app/components/simple-input";
import { ApiResponse, ApiResponseError, ApiResponseSuccess } from "@/app/interfaces/search-results";
import { clamp } from "@/lib/helpers";
import nextConfig from "@/next.config";

const MIN_PAGE = 1;
const MAX_PAGE = 100000;
const MIN_SIZE = 1;
const MAX_SIZE = 100;

type SearchQuery = {
    q: string;
    page: number;
    size: number;
    applicant: string;
    inventor: string;
    assignee: string;
    tag: string;
    documentName: string;
    specialMentionMatterArticle: string;
    rejectionReasonArticle: string;
    priorityClaims: string;
};

type AggregationKey = keyof ApiResponseSuccess["aggregations"];
type FilterParam = Exclude<keyof SearchQuery, "q" | "page" | "size">;

type FilterDefinition = {
    key: AggregationKey;
    label: string;
    param: FilterParam;
};

const FILTERS: FilterDefinition[] = [
    { key: "applicants", label: "出願人", param: "applicant" },
    { key: "inventors", label: "発明者", param: "inventor" },
    { key: "assignees", label: "担当者", param: "assignee" },
    { key: "tags", label: "タグ", param: "tag" },
    { key: "documentNames", label: "文書名", param: "documentName" },
    { key: "specialMentionMatterArticle", label: "特記事項", param: "specialMentionMatterArticle" },
    { key: "rejectionReasonArticle", label: "拒絶理由", param: "rejectionReasonArticle" },
    { key: "priorityClaims", label: "優先権", param: "priorityClaims" },
];

function parseSearchQuery(sp: ReturnType<typeof useSearchParams>): SearchQuery {
    return {
        q: sp.get("q") ?? "",
        page: clamp(Number(sp.get("page") ?? "1") || 1, MIN_PAGE, MAX_PAGE),
        size: clamp(Number(sp.get("size") ?? "10") || 10, MIN_SIZE, MAX_SIZE),
        applicant: sp.get("applicant") ?? "",
        inventor: sp.get("inventor") ?? "",
        assignee: sp.get("assignee") ?? "",
        tag: sp.get("tag") ?? "",
        documentName: sp.get("documentName") ?? "",
        specialMentionMatterArticle: sp.get("specialMentionMatterArticle") ?? "",
        rejectionReasonArticle: sp.get("rejectionReasonArticle") ?? "",
        priorityClaims: sp.get("priorityClaims") ?? "",
    };
}

function buildSearchParams(query: SearchQuery): URLSearchParams {
    const params = new URLSearchParams();

    if (query.q.trim()) params.set("q", query.q.trim());
    params.set("page", String(query.page));
    params.set("size", String(query.size));

    FILTERS.forEach(({ param }) => {
        const value = query[param];
        if (value) params.set(param, value);
    });

    return params;
}

function SearchPageContent() {
    const router = useRouter();
    const sp = useSearchParams();
    const queryFromUrl = parseSearchQuery(sp);

    const [q, setQ] = useState(queryFromUrl.q);
    const [page, setPage] = useState(queryFromUrl.page);
    const [size, setSize] = useState(queryFromUrl.size);
    const [filters, setFilters] = useState<Record<FilterParam, string>>({
        applicant: queryFromUrl.applicant,
        inventor: queryFromUrl.inventor,
        assignee: queryFromUrl.assignee,
        tag: queryFromUrl.tag,
        documentName: queryFromUrl.documentName,
        specialMentionMatterArticle: queryFromUrl.specialMentionMatterArticle,
        rejectionReasonArticle: queryFromUrl.rejectionReasonArticle,
        priorityClaims: queryFromUrl.priorityClaims,
    });

    const [loading, setLoading] = useState(false);
    const [data, setData] = useState<ApiResponseSuccess | null>(null);
    const [err, setErr] = useState<string | null>(null);

    useEffect(() => {
        setQ(queryFromUrl.q);
        setPage(queryFromUrl.page);
        setSize(queryFromUrl.size);
        setFilters({
            applicant: queryFromUrl.applicant,
            inventor: queryFromUrl.inventor,
            assignee: queryFromUrl.assignee,
            tag: queryFromUrl.tag,
            documentName: queryFromUrl.documentName,
            specialMentionMatterArticle: queryFromUrl.specialMentionMatterArticle,
            rejectionReasonArticle: queryFromUrl.rejectionReasonArticle,
            priorityClaims: queryFromUrl.priorityClaims,
        });
    }, [
        queryFromUrl.q,
        queryFromUrl.page,
        queryFromUrl.size,
        queryFromUrl.applicant,
        queryFromUrl.inventor,
        queryFromUrl.assignee,
        queryFromUrl.tag,
        queryFromUrl.documentName,
        queryFromUrl.specialMentionMatterArticle,
        queryFromUrl.rejectionReasonArticle,
        queryFromUrl.priorityClaims,
    ]);

    const fetchSearch = useCallback(async (query: SearchQuery) => {
        const params = buildSearchParams(query);

        setLoading(true);
        setErr(null);
        try {
            const res = await fetch(`/api/search?${params.toString()}`, {
                method: "GET",
                headers: { "Content-Type": "application/json" },
            });
            const json: ApiResponse = await res.json();
            if (!res.ok) {
                const e = json as ApiResponseError;
                throw new Error(e?.message || e?.error || `HTTP ${res.status}`);
            }
            setData(json as ApiResponseSuccess);
        } catch (e: unknown) {
            setErr((e as Error)?.message ?? String(e));
            setData(null);
        } finally {
            setLoading(false);
        }
    }, []);

    useEffect(() => {
        fetchSearch(queryFromUrl);
    }, [
        fetchSearch,
        queryFromUrl.q,
        queryFromUrl.page,
        queryFromUrl.size,
        queryFromUrl.applicant,
        queryFromUrl.inventor,
        queryFromUrl.assignee,
        queryFromUrl.tag,
        queryFromUrl.documentName,
        queryFromUrl.specialMentionMatterArticle,
        queryFromUrl.rejectionReasonArticle,
        queryFromUrl.priorityClaims,
    ]);

    function pushQuery(next: SearchQuery) {
        router.push(`/search?${buildSearchParams(next).toString()}`);
    }

    function submit() {
        pushQuery({ ...queryFromUrl, ...filters, q, size, page: 1 });
    }

    function onFilterChange(param: FilterParam, value: string) {
        const nextFilters = { ...filters, [param]: value };
        setFilters(nextFilters);
        pushQuery({ ...queryFromUrl, ...nextFilters, q, size, page: 1 });
    }

    const totalPages = data ? Math.max(1, Math.ceil(data.total / data.size)) : 1;

    return (
        <div className="max-w-[980px] mx-auto my-6">
            <div className="bg-white sticky top-12 z-40 px-2 py-4">
                <SimpleInput value={q} onChange={setQ} onSubmit={submit} size={size} onSizeChange={setSize} />

                <div className="flex justify-center">
                    <Pagination
                        currentPage={page}
                        totalPages={totalPages}
                        loading={loading}
                        totalItems={data?.total}
                        onPageChange={(newPage) => {
                            const clampedPage = clamp(newPage, MIN_PAGE, Math.min(totalPages, MAX_PAGE));
                            pushQuery({
                                ...queryFromUrl,
                                ...filters,
                                q: queryFromUrl.q,
                                size: queryFromUrl.size,
                                page: clampedPage,
                            });
                        }}
                    />
                </div>

                <div className="flex gap-4 flex-wrap">
                    {FILTERS.map((filter) => {
                        const aggregation = data?.aggregations?.[filter.key];
                        if (!aggregation || aggregation.length === 0) return null;

                        return (
                            <div key={filter.key} className="flex-1 min-w-[220px]">
                                <label className="text-sm font-semibold text-gray-700 mb-1 block">{filter.label}</label>
                                <select
                                    value={filters[filter.param]}
                                    onChange={(e) => onFilterChange(filter.param, e.target.value)}
                                    className="w-full px-3 py-2 border border-gray-300 rounded text-sm"
                                >
                                    <option value="">すべて</option>
                                    {aggregation.slice(0, 20).map((bucket) => (
                                        <option key={bucket.key} value={bucket.key}>
                                            {bucket.key} ({bucket.doc_count})
                                        </option>
                                    ))}
                                </select>
                            </div>
                        );
                    })}
                </div>
            </div>

            {err && <ErrorMessage err={err} />}

            {data && (
                <div className="flex flex-col gap-2 mt-3">
                    {data.hits.map((hit) => (
                        <div key={hit.id} className="border border-gray-300 rounded-xl p-3">
                            <HitResults hitResult={hit} keywords={queryFromUrl.q} />
                        </div>
                    ))}
                    {data.hits.length === 0 && (
                        <div className="text-gray-600 p-3 border border-gray-300 rounded-xl text-center">ヒットがありませんでした。</div>
                    )}
                </div>
            )}
        </div>
    );
}

export default function SearchPage() {
    return (
        <Suspense fallback={<div className="max-w-[980px] mx-auto my-6 text-center">読み込み中...</div>}>
            <SearchPageContent />
        </Suspense>
    );
}
