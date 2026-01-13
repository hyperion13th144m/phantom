"use client";

import { Suspense, useEffect, useState } from "react";
import { useSearchParams, useRouter } from "next/navigation";
import ErrorMessage from "@/app/components/error-message";
import SimpleInput from "@/app/components/simple-input";
import Pagination from "@/app/components/pagination";
import Highlight from "@/app/components/highlight";
import ImagesArray from "@/app/components/images-array";
import { clamp, buildImageUrl, formatApplicationNumber, formatDate } from "@/lib/helpers";
import { getEnv } from "@/lib/env";

type Hit = {
    id: string;
    score: number | null;
    source: {
        law: string;
        applicationNumber: string;
        submissionDate: string;
        fileReferenceId: string;
        inventionTitle?: string;
        independentClaims?: string;
        dependentClaims?: string;
        abstract?: string;
        applicants?: string[];
        inventors?: string[];
        assignee?: string;
        tags?: string[];
        images: {
            number: string;
            filename: string;
            kind: string;
            sizeTag: string;
            width: number;
            height: number;
            description: string;
            representative: boolean;
        }[];
        documentUrl: string;
    };
    highlight: Record<string, string[]>;
};

type ApiResponse = {
    page: number;
    size: number;
    total: number;
    hits: Hit[];
    aggregations: {
        applicants: { key: string; doc_count: number }[];
        inventors: { key: string; doc_count: number }[];
    }
    error?: string;
    message?: string;
};


function SearchPageContent() {
    const router = useRouter();
    const sp = useSearchParams();

    const q0 = sp.get("q") ?? "";
    const page0 = Number(sp.get("page") ?? "1") || 1;
    const size0 = Number(sp.get("size") ?? "10") || 10;
    const applicant0 = sp.get("applicant") ?? "";
    const inventor0 = sp.get("inventor") ?? "";

    const [q, setQ] = useState(q0);
    const [page, setPage] = useState(clamp(page0, 1, 100000));
    const [size, setSize] = useState(clamp(size0, 1, 100));
    const [selectedApplicant, setSelectedApplicant] = useState(applicant0);
    const [selectedInventor, setSelectedInventor] = useState(inventor0);
    const [loading, setLoading] = useState(false);
    const [data, setData] = useState<ApiResponse | null>(null);
    const [err, setErr] = useState<string | null>(null);
    const [images, setImages] = useState<Record<string, (Hit["source"]["images"][number] & { largeFilename: string })[]>>({});

    useEffect(() => {
        // 初期値がURL由来なので、URLが変わったら入力も追随させる
        setQ(q0);
        setPage(clamp(page0, 1, 100000));
        setSize(clamp(size0, 1, 100));
    }, [q0, page0, size0]);

    async function fetchSearch(params: { q: string; page: number; size: number; applicant?: string; inventor?: string }) {
        const usp = new URLSearchParams();
        if (params.q.trim()) usp.set("q", params.q.trim());
        usp.set("page", String(params.page));
        usp.set("size", String(params.size));
        if (params.applicant) usp.set("applicant", params.applicant);
        if (params.inventor) usp.set("inventor", params.inventor);

        setLoading(true);
        setErr(null);
        try {
            const res = await fetch(`/api/search?${usp.toString()}`, {
                method: "GET",
                headers: { "Content-Type": "application/json" },
            });
            const json: ApiResponse = await res.json();
            if (!res.ok) {
                throw new Error(json?.message || json?.error || `HTTP ${res.status}`);
            }
            setData(json);
        } catch (e: unknown) {
            setErr((e as Error)?.message ?? String(e));
            setData(null);
        } finally {
            setLoading(false);
        }
    }

    // URLクエリが変わったら検索実行
    useEffect(() => {
        fetchSearch({ q: q0, page: clamp(page0, 1, 100000), size: clamp(size0, 1, 100), applicant: applicant0, inventor: inventor0 });
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [q0, page0, size0, applicant0, inventor0]);

    function submit() {
        // 新しい検索は1ページ目から
        const p = new URLSearchParams();
        if (q.trim()) p.set("q", q.trim());
        p.set("page", "1");
        p.set("size", String(size));
        if (selectedApplicant) p.set("applicant", selectedApplicant);
        if (selectedInventor) p.set("inventor", selectedInventor);
        router.push(`/search?${p.toString()}`);
    }

    useEffect(() => {
        if (data?.hits) {
            const newImages: Record<string, (Hit["source"]["images"][number] & { largeFilename: string })[]> = {};
            data.hits.forEach((hit) => {
                if (hit.source.images) {
                    const images = hit.source.images
                        .filter((img) => img.kind === "figure")
                    const thumbnails = images
                        .filter((img) => img.sizeTag === "thumbnail")
                        .sort((a, b) => a.filename.localeCompare(b.filename))
                        .slice(0, 5);
                    const largeImages = images
                        .filter((img) => img.sizeTag === "large")
                        .sort((a, b) => a.filename.localeCompare(b.filename))
                        .slice(0, 5);
                    newImages[hit.id] = thumbnails.map((thumb, idx) => (
                        {
                            ...thumb,
                            largeFilename: largeImages[idx]?.filename || "",
                        }
                    ));
                }
            });
            setImages(newImages);
        }
    }, [data]);


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
                    {data?.aggregations?.applicants && data.aggregations.applicants.length > 0 && (
                        <div className="flex-1 min-w-[250px]">
                            <label className="text-sm font-semibold text-gray-700 mb-1 block">出願人で絞り込み</label>
                            <select
                                value={selectedApplicant}
                                onChange={(e) => {
                                    setSelectedApplicant(e.target.value);
                                    const p = new URLSearchParams();
                                    if (q.trim()) p.set("q", q.trim());
                                    p.set("page", "1");
                                    p.set("size", String(size));
                                    if (e.target.value) p.set("applicant", e.target.value);
                                    if (selectedInventor) p.set("inventor", selectedInventor);
                                    router.push(`/search?${p.toString()}`);
                                }}
                                className="w-full px-3 py-2 border border-gray-300 rounded text-sm"
                            >
                                <option value="">すべて</option>
                                {data.aggregations.applicants.slice(0, 20).map((bucket) => (
                                    <option key={bucket.key} value={bucket.key}>
                                        {bucket.key} ({bucket.doc_count})
                                    </option>
                                ))}
                            </select>
                        </div>
                    )}

                    {data?.aggregations?.inventors && data.aggregations.inventors.length > 0 && (
                        <div className="flex-1 min-w-[250px]">
                            <label className="text-sm font-semibold text-gray-700 mb-1 block">発明者で絞り込み</label>
                            <select
                                value={selectedInventor}
                                onChange={(e) => {
                                    setSelectedInventor(e.target.value);
                                    const p = new URLSearchParams();
                                    if (q.trim()) p.set("q", q.trim());
                                    p.set("page", "1");
                                    p.set("size", String(size));
                                    if (selectedApplicant) p.set("applicant", selectedApplicant);
                                    if (e.target.value) p.set("inventor", e.target.value);
                                    router.push(`/search?${p.toString()}`);
                                }}
                                className="w-full px-3 py-2 border border-gray-300 rounded text-sm"
                            >
                                <option value="">すべて</option>
                                {data.aggregations.inventors.slice(0, 20).map((bucket) => (
                                    <option key={bucket.key} value={bucket.key}>
                                        {bucket.key} ({bucket.doc_count})
                                    </option>
                                ))}
                            </select>
                        </div>
                    )}
                </div>
            </div>

            {err && (
                <ErrorMessage err={err} />
            )}

            {data && (
                <div className="flex flex-col gap-2 mt-3">
                    {data.hits.map((h) => (
                        <div key={h.id} className="border border-gray-300 rounded-xl p-3">
                            <div>
                                <div className="flex justify-between items-center font-extrabold text-lg mb-1.5">
                                    <div>
                                        {h.source.inventionTitle ?? "(no title)"}{" "}
                                    </div>
                                    <div>
                                        <a href={`${h.source.documentUrl}?q=${q0.split(/ /).join(',')}`}
                                            target="_blank" rel="noopener noreferrer" className="ml-2 text-xs">
                                            詳細
                                        </a>
                                        <span className="font-normal text-xs text-gray-600">
                                            {h.score != null ? ` スコア=${h.score.toFixed(2)}` : ""}
                                        </span>
                                    </div>
                                </div>

                                <div className="flex flex-wrap justify-start text-gray-800 text-sm mt-2 gap-4">
                                    <div>整理番号: {h.source.fileReferenceId ?? "-"}</div>
                                    <div>出願番号: {formatApplicationNumber(h.source.law ?? "-", h.source.applicationNumber ?? "-")}</div>
                                    <div>出願日: {formatDate(h.source.submissionDate ?? "-")}</div>
                                    <div>出願人: {(h.source.applicants ?? []).join(", ") || "-"}</div>
                                </div>
                            </div>

                            <hr className="my-3 border-gray-300" />

                            {/* ハイライトがあれば表示 */}
                            {Object.keys(h.highlight || {}).length > 0 && (
                                <div className="text-13/1.6">
                                    <Highlight highlight={h.highlight} />
                                </div>
                            )}

                            {/* 画像表示 */}
                            {images[h.id] !== undefined && images[h.id].length > 0 && (
                                <div className="mt-3">
                                    <ImagesArray images={images[h.id]} />
                                </div>
                            )}
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
