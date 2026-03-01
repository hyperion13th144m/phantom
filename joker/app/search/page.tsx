"use client";

import { Suspense, useEffect, useState } from "react";
import { useSearchParams, useRouter } from "next/navigation";
import ErrorMessage from "@/app/components/error-message";
import SimpleInput from "@/app/components/simple-input";
import Pagination from "@/app/components/pagination";
import HitResults from "../components/hit-results";
import { clamp } from "@/lib/helpers";
import nextConfig from "../../next.config";
import { ApiResponse, ApiResponseSuccess, ApiResponseError, Hit } from "@/app/interfaces/search-results";

function SearchPageContent() {
    const router = useRouter();
    const sp = useSearchParams();

    const q0 = sp.get("q") ?? "";
    const page0 = Number(sp.get("page") ?? "1") || 1;
    const size0 = Number(sp.get("size") ?? "10") || 10;
    const applicant0 = sp.get("applicant") ?? "";
    const inventor0 = sp.get("inventor") ?? "";
    const assignee0 = sp.get("assignee") ?? "";
    const tag0 = sp.get("tag") ?? "";
    const documentName0 = sp.get("documentName") ?? "";
    const specialMentionMatterArticle0 = sp.get("specialMentionMatterArticle") ?? "";
    const rejectionReasonArticle0 = sp.get("rejectionReasonArticle") ?? "";
    const priorityClaims0 = sp.get("priorityClaims") ?? "";

    const [q, setQ] = useState(q0);
    const [page, setPage] = useState(clamp(page0, 1, 100000));
    const [size, setSize] = useState(clamp(size0, 1, 100));
    const [selectedApplicant, setSelectedApplicant] = useState(applicant0);
    const [selectedInventor, setSelectedInventor] = useState(inventor0);
    const [selectedAssignee, setSelectedAssignee] = useState(assignee0);
    const [selectedTag, setSelectedTag] = useState(tag0);
    const [selectedDocumentName, setSelectedDocumentName] = useState(documentName0);
    const [selectedSpecialMentionMatterArticle, setSelectedSpecialMentionMatterArticle] = useState(specialMentionMatterArticle0);
    const [selectedRejectionReasonArticle, setSelectedRejectionReasonArticle] = useState(rejectionReasonArticle0);
    const [selectedPriorityClaims, setSelectedPriorityClaims] = useState(priorityClaims0);
    const [loading, setLoading] = useState(false);
    const [data, setData] = useState<ApiResponseSuccess | null>(null);
    const [err, setErr] = useState<string | null>(null);

    useEffect(() => {
        // 初期値がURL由来なので、URLが変わったら入力も追随させる
        setQ(q0);
        setPage(clamp(page0, 1, 100000));
        setSize(clamp(size0, 1, 100));
    }, [q0, page0, size0]);

    async function fetchSearch(params: {
        q: string; page: number; size: number;
        applicant?: string; inventor?: string, assignee?: string; tag?: string,
        documentName?: string, specialMentionMatterArticle?: string,
        rejectionReasonArticle?: string, priorityClaims?: string
    }) {
        const usp = new URLSearchParams();
        if (params.q.trim()) usp.set("q", params.q.trim());
        usp.set("page", String(params.page));
        usp.set("size", String(params.size));
        if (params.applicant) usp.set("applicant", params.applicant);
        if (params.inventor) usp.set("inventor", params.inventor);
        if (params.assignee) usp.set("assignee", params.assignee);
        if (params.tag) usp.set("tag", params.tag);
        if (params.documentName) usp.set("documentName", params.documentName);
        if (params.specialMentionMatterArticle) usp.set("specialMentionMatterArticle", params.specialMentionMatterArticle);
        if (params.rejectionReasonArticle) usp.set("rejectionReasonArticle", params.rejectionReasonArticle);
        if (params.priorityClaims) usp.set("priorityClaims", params.priorityClaims);

        setLoading(true);
        setErr(null);
        try {
            const res = await fetch(`${nextConfig.basePath}/api/search?${usp.toString()}`, {
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
    }

    // URLクエリが変わったら検索実行
    useEffect(() => {
        fetchSearch({ q: q0, page: clamp(page0, 1, 100000), size: clamp(size0, 1, 100), applicant: applicant0, inventor: inventor0, assignee: assignee0, tag: tag0, documentName: documentName0, specialMentionMatterArticle: specialMentionMatterArticle0, rejectionReasonArticle: rejectionReasonArticle0, priorityClaims: priorityClaims0 });
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [q0, page0, size0, applicant0, inventor0, assignee0, tag0, documentName0, specialMentionMatterArticle0, rejectionReasonArticle0, priorityClaims0]);

    function submit() {
        // 新しい検索は1ページ目から
        const p = new URLSearchParams();
        if (q.trim()) p.set("q", q.trim());
        p.set("page", "1");
        p.set("size", String(size));
        if (selectedApplicant) p.set("applicant", selectedApplicant);
        if (selectedInventor) p.set("inventor", selectedInventor);
        if (selectedAssignee) p.set("assignee", selectedAssignee);
        if (selectedTag) p.set("tag", selectedTag);
        if (selectedDocumentName) p.set("documentName", selectedDocumentName);
        if (selectedSpecialMentionMatterArticle) p.set("specialMentionMatterArticle", selectedSpecialMentionMatterArticle);
        if (selectedRejectionReasonArticle) p.set("rejectionReasonArticle", selectedRejectionReasonArticle);
        if (selectedPriorityClaims) p.set("priorityClaims", selectedPriorityClaims);
        router.push(`/search?${p.toString()}`);
    }

    const totalPages = data ? Math.max(1, Math.ceil(data.total / data.size)) : 1;

    return (
        <div className="max-w-[980px] mx-auto my-6"
            style={{}}>
            <div className="bg-white/90 sticky top-12 z-40 px-2 py-4">
                <SimpleInput
                    value={q}
                    onChange={setQ}
                    onSubmit={submit}
                    size={size}
                    onSizeChange={setSize}
                />

                <div className="flex justify-center">
                    <Pagination
                        currentPage={page}
                        totalPages={totalPages}
                        loading={loading}
                        totalItems={data?.total}
                        onPageChange={(newPage) => {
                            const clampedPage = clamp(newPage, 1, totalPages);
                            router.push(`/search?q=${encodeURIComponent(q0)}&page=${clampedPage}&size=${size0}`);
                        }}
                    />
                </div>

                {/* 絞り込みUI */}
                <div className="flex gap-4 flex-wrap">
                    {[
                        {
                            key: "applicants" as const,
                            label: "出願人で絞り込み",
                            param: "applicant",
                            value: selectedApplicant,
                            setValue: setSelectedApplicant
                        },
                        {
                            key: "inventors" as const,
                            label: "発明者で絞り込み",
                            param: "inventor",
                            value: selectedInventor,
                            setValue: setSelectedInventor
                        },
                        {
                            key: "assignees" as const,
                            label: "担当者で絞り込み",
                            param: "assignee",
                            value: selectedAssignee,
                            setValue: setSelectedAssignee
                        },
                        {
                            key: "tags" as const,
                            label: "タグで絞り込み",
                            param: "tag",
                            value: selectedTag,
                            setValue: setSelectedTag
                        },
                        {
                            key: "documentNames" as const,
                            label: "文書名で絞り込み",
                            param: "documentName",
                            value: selectedDocumentName,
                            setValue: setSelectedDocumentName
                        },
                        {
                            key: "specialMentionMatterArticle" as const,
                            label: "特記事項で絞り込み",
                            param: "specialMentionMatterArticle",
                            value: selectedSpecialMentionMatterArticle,
                            setValue: setSelectedSpecialMentionMatterArticle
                        },
                        {
                            key: "rejectionReasonArticle" as const,
                            label: "拒絶理由で絞り込み",
                            param: "rejectionReasonArticle",
                            value: selectedRejectionReasonArticle,
                            setValue: setSelectedRejectionReasonArticle
                        },
                        {
                            key: "priorityClaims" as const,
                            label: "優先権有無で絞り込み",
                            param: "priorityClaims",
                            value: selectedPriorityClaims,
                            setValue: setSelectedPriorityClaims
                        },
                    ].map((filter) => {
                        const aggregation = data?.aggregations?.[filter.key];
                        if (!aggregation || aggregation.length === 0) return null;

                        return (
                            <div key={filter.key} className="flex-1 min-w-[220px]">
                                <label className="text-sm font-semibold text-gray-700 mb-1 block">{filter.label}</label>
                                <select
                                    value={filter.value}
                                    onChange={(e) => {
                                        const newValue = e.target.value;
                                        filter.setValue(newValue);
                                        const p = new URLSearchParams();
                                        if (q.trim()) p.set("q", q.trim());
                                        p.set("page", "1");
                                        p.set("size", String(size));

                                        // 現在変更中のパラメータは新しい値を、それ以外は既存の値を設定
                                        const currentApplicant = filter.param === "applicant" ? newValue : selectedApplicant;
                                        const currentInventor = filter.param === "inventor" ? newValue : selectedInventor;
                                        const currentAssignee = filter.param === "assignee" ? newValue : selectedAssignee;
                                        const currentTag = filter.param === "tag" ? newValue : selectedTag;
                                        const currentDocumentName = filter.param === "documentName" ? newValue : selectedDocumentName;
                                        const currentSpecialMentionMatterArticle = filter.param === "specialMentionMatterArticle" ? newValue : selectedSpecialMentionMatterArticle;
                                        const currentRejectionReasonArticle = filter.param === "rejectionReasonArticle" ? newValue : selectedRejectionReasonArticle;
                                        const currentPriorityClaims = filter.param === "priorityClaims" ? newValue : selectedPriorityClaims;
                                        if (currentApplicant) p.set("applicant", currentApplicant);
                                        if (currentInventor) p.set("inventor", currentInventor);
                                        if (currentAssignee) p.set("assignee", currentAssignee);
                                        if (currentTag) p.set("tag", currentTag);
                                        if (currentDocumentName) p.set("documentName", currentDocumentName);
                                        if (currentSpecialMentionMatterArticle) p.set("specialMentionMatterArticle", currentSpecialMentionMatterArticle);
                                        if (currentRejectionReasonArticle) p.set("rejectionReasonArticle", currentRejectionReasonArticle);
                                        if (currentPriorityClaims) p.set("priorityClaims", currentPriorityClaims);
                                        router.push(`/search?${p.toString()}`);
                                    }}
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

            {err && (
                <ErrorMessage err={err} />
            )}

            {data && (
                <div className="flex flex-col gap-2 mt-3">
                    {data.hits.map((h) => (
                        <div key={h.id} className="border border-gray-300 rounded-xl p-3">
                            <HitResults hitResult={h} keywords={q0} />
                        </div>
                    ))}
                    {data.hits.length === 0 && (
                        <div className="text-gray-600 p-3 border border-gray-300 rounded-xl text-center">
                            ヒットがありませんでした。
                        </div>
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
