"use client";

import React, { useEffect, useMemo, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { ApiResponse, ApiResponseError, ApiResponseSuccess } from "@/app/interfaces/search-results";
import { clamp } from "@/lib/helpers";
import { formatApplicationNumber } from "@/lib/helpers";

type Meta = {
    docId: string;
    assignees: string[];
    tags: string[];
    extraNumbers: string[];
    updatedAt: string;
    updatedBy: string | null;
    version: number;
};

type ByIdsResp = {
    byId: Record<string, Meta>;
};

type BulkResult = {
    updatedAt: string;
    results: Array<{ docId: string; ok: boolean; status?: number; error?: string; version?: number }>;
};

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
    params.set("withHighlight", "false");

    FILTERS.forEach(({ param }) => {
        const value = query[param];
        if (value) params.set(param, value);
    });

    return params;
}

function uniqKeepOrder(xs: string[]) {
    const seen = new Set<string>();
    const out: string[] = [];
    for (const x of xs) {
        const v = x.trim();
        if (!v) continue;
        if (seen.has(v)) continue;
        seen.add(v);
        out.push(v);
    }
    return out;
}
function splitInputToTokens(s: string) {
    return s.replace(/[，、]/g, ",").split(",").map(v => v.trim()).filter(Boolean);
}

function ChipEditor(props: {
    value: string[];
    placeholder?: string;
    suggestions?: string[];
    onChange: (next: string[]) => void;
}) {
    const { value, onChange, placeholder, suggestions } = props;
    const [input, setInput] = useState("");

    const addTokens = (tokens: string[]) => onChange(uniqKeepOrder([...value, ...tokens]));

    const onKeyDown: React.KeyboardEventHandler<HTMLInputElement> = (e) => {
        if (e.key === "Enter" || e.key === "," || e.key === "Tab") {
            if (e.key !== "Tab") e.preventDefault();
            const tokens = splitInputToTokens(input);
            if (tokens.length) addTokens(tokens);
            setInput("");
        }
        if (e.key === "Backspace" && !input && value.length) {
            onChange(value.slice(0, -1));
        }
    };

    const removeAt = (idx: number) => {
        const next = value.slice();
        next.splice(idx, 1);
        onChange(next);
    };

    return (
        <div className="flex flex-wrap gap-1 rounded border border-slate-300 bg-white px-2 py-1">
            {value.map((v, idx) => (
                <span key={`${v}-${idx}`} className="inline-flex items-center gap-1 rounded-full border border-slate-300 bg-slate-50 px-2 py-0.5 text-xs">
                    <span className="max-w-[220px] truncate">{v}</span>
                    <button type="button" className="rounded-full px-1 text-slate-500 hover:bg-slate-200 hover:text-slate-700" onClick={() => removeAt(idx)}>
                        ×
                    </button>
                </span>
            ))}
            <input
                className="min-w-[140px] flex-1 border-0 bg-transparent p-1 text-sm outline-none"
                value={input}
                onChange={(e) => setInput(e.target.value)}
                onKeyDown={onKeyDown}
                placeholder={placeholder ?? "追加（Enter / ,）"}
                list={suggestions?.length ? "chip-suggestions" : undefined}
            />
            {suggestions?.length ? (
                <datalist id="chip-suggestions">
                    {suggestions.map((s) => <option value={s} key={s} />)}
                </datalist>
            ) : null}
        </div>
    );
}

export default function MetadataOnSearchGrid() {
    const router = useRouter();
    const sp = useSearchParams();
    const queryFromUrl = parseSearchQuery(sp);
    const [q, setQ] = useState("");
    const [page, setPage] = useState(1);
    const [size] = useState(25);
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
    const [esData, setEsData] = useState<ApiResponseSuccess | null>(null);
    const [metaById, setMetaById] = useState<Record<string, Meta>>({});
    const [error, setError] = useState<string | null>(null);
    const [saveMsg, setSaveMsg] = useState<string | null>(null);

    useEffect(() => {
        setQ(queryFromUrl.q);
        setPage(queryFromUrl.page);
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
        queryFromUrl.applicant,
        queryFromUrl.inventor,
        queryFromUrl.assignee,
        queryFromUrl.tag,
        queryFromUrl.documentName,
        queryFromUrl.specialMentionMatterArticle,
        queryFromUrl.rejectionReasonArticle,
        queryFromUrl.priorityClaims,
    ]);

    // dirty: docId -> edits + expectedVersion
    const [dirty, setDirty] = useState<Record<
        string,
        Partial<Pick<Meta, "assignees" | "tags" | "extraNumbers">> & { expectedVersion: number }
    >>({});

    const totalPages = useMemo(() => {
        if (!esData) return 1;
        return Math.max(1, Math.ceil(esData.total / esData.size));
    }, [esData]);

    const fetchMetaByIds = async (docIds: string[]) => {
        if (!docIds.length) { setMetaById({}); return; }
        const res = await fetch("/api/metadata/byIds", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ docIds }),
        });
        if (!res.ok) throw new Error(`POST /api/metadata/byIds failed: ${res.status}`);
        const json = (await res.json()) as ByIdsResp;
        setMetaById(json.byId ?? {});
    };

    const fetchEsAndMeta = async () => {
        setLoading(true);
        setError(null);
        setSaveMsg(null);
        try {
            const params = buildSearchParams({ ...queryFromUrl, q });
            const res = await fetch(`/api/search?${params.toString()}`, { cache: "no-store" });
            if (!res.ok) throw new Error(`GET /api/search failed: ${res.status}`);
            const json = (await res.json()) as ApiResponseSuccess;
            setEsData(json);

            const docIds = json.hits.map(r => r.source?.docId).filter((id): id is string => typeof id === "string");
            await fetchMetaByIds(docIds);

            // 検索条件が変わったら dirty は破棄する方が事故が少ない（おすすめ）
            setDirty({});
        } catch (e: any) {
            setError(e?.message ?? String(e));
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => { fetchEsAndMeta(); }, [page,
        queryFromUrl.q,
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
        router.push(`/metadata?${buildSearchParams(next).toString()}`);
    }

    function onFilterChange(param: FilterParam, value: string) {
        const nextFilters = { ...filters, [param]: value };
        setFilters(nextFilters);
        pushQuery({ ...queryFromUrl, ...nextFilters, q, size, page: 1 });
    }


    const esRows = esData?.hits ?? [];

    // 候補は「現在ページのメタ＋dirty」から簡易生成（必要なら専用APIに）
    const tagSuggestions = useMemo(() => {
        const s = new Set<string>();
        for (const r of esRows) ((r.source.docId ? metaById[r.source.docId]?.tags : []) ?? []).forEach(t => s.add(t));
        return Array.from(s).slice(0, 200);
    }, [esRows, metaById]);

    const assigneeSuggestions = useMemo(() => {
        const s = new Set<string>();
        for (const r of esRows) ((r.source.docId ? metaById[r.source.docId]?.assignees : []) ?? []).forEach(t => s.add(t));
        return Array.from(s).slice(0, 200);
    }, [esRows, metaById]);

    const baseMeta = (docId: string): Meta => {
        const m = metaById[docId];
        // メタが無い場合のデフォルト（version=0扱いでOK。bulk側は expectedVersion を無視しても良いが、ここでは 0 を使う）
        return m ?? {
            docId,
            assignees: [],
            tags: [],
            extraNumbers: [],
            updatedAt: new Date(0).toISOString(),
            updatedBy: null,
            version: 0,
        };
    };

    const mergedMeta = (docId: string): Meta => {
        const base = baseMeta(docId);
        const d = dirty[docId];
        if (!d) return base;
        return {
            ...base,
            assignees: d.assignees ?? base.assignees,
            tags: d.tags ?? base.tags,
            extraNumbers: d.extraNumbers ?? base.extraNumbers,
        };
    };

    const setField = (docId: string, patch: Partial<Meta>) => {
        const base = baseMeta(docId);
        setDirty(prev => {
            const cur = prev[docId] ?? { expectedVersion: base.version };
            return {
                ...prev,
                [docId]: {
                    ...cur,
                    expectedVersion: cur.expectedVersion ?? base.version,
                    ...patch,
                },
            };
        });
    };

    const dirtyCount = Object.keys(dirty).length;

    const saveBulk = async () => {
        setSaveMsg(null);
        setError(null);
        const updates = Object.entries(dirty).map(([docId, d]) => ({
            docId,
            assignees: d.assignees,
            tags: d.tags,
            extraNumbers: d.extraNumbers,
            expectedVersion: d.expectedVersion,
        }));
        if (!updates.length) { setSaveMsg("変更はありません。"); return; }

        try {
            const res = await fetch("/api/metadata/bulk", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ updates }),
            });
            const json = (await res.json()) as BulkResult;
            if (!res.ok) throw new Error((json as any)?.error ?? `bulk failed: ${res.status}`);

            const ok = json.results.filter(r => r.ok);
            const ng = json.results.filter(r => !r.ok);

            // 成功分だけ dirty から消す
            setDirty(prev => {
                const next = { ...prev };
                for (const r of ok) delete next[r.docId];
                return next;
            });

            // いま表示してるdocIdのメタだけ再取得（ES検索し直さなくていい）
            const docIds = esRows.map(r => r.source.docId).filter((id): id is string => typeof id === "string");
            await fetchMetaByIds(docIds);

            setSaveMsg(
                ng.length
                    ? `保存：成功 ${ok.length} / 失敗 ${ng.length}（失敗行は残しています）`
                    : `保存しました（${ok.length}件）`
            );
        } catch (e: any) {
            setError(e?.message ?? String(e));
        }
    };

    const filterForm = (
        <div className="flex gap-4 flex-wrap">
            {FILTERS.map((filter) => {
                const aggregation = esData?.aggregations?.[filter.key];
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
    );

    return (
        <div className="mx-auto max-w-7xl p-6">
            <div>
                <h1 className="text-xl font-semibold">検索結果にメタデータを付与</h1>
                <p className="text-sm text-slate-600">
                    Elasticsearchの検索結果（docId）に対して、担当者・タグ・整理番号を編集し保存します。
                </p>
            </div>

            <div className="mb-4 flex flex-col gap-3 sm:flex-row sm:items-end sm:justify-between">
                <div className="flex flex-col gap-2 sm:flex-row sm:items-center">
                    <div className="flex items-center gap-2">
                        <input
                            className="w-120 rounded border border-slate-300 px-3 py-2 text-sm outline-none focus:border-slate-500"
                            placeholder="全文検索（タイトル/請求項/要約/出願人/整理番号/出願番号など）"
                            value={q}
                            onChange={(e) => setQ(e.target.value)}
                            onKeyDown={(e) => {
                                if (e.key === "Enter") {
                                    setPage(1);
                                    fetchEsAndMeta();
                                }
                            }}
                        />
                        <button
                            className="rounded bg-slate-900 px-3 py-2 text-sm text-white hover:bg-slate-800 disabled:opacity-50"
                            onClick={() => { setPage(1); fetchEsAndMeta(); }}
                            disabled={loading}
                        >
                            検索
                        </button>
                    </div>

                    <div className="flex items-center gap-2">
                        <button
                            className="rounded bg-emerald-600 px-3 py-2 text-sm text-white hover:bg-emerald-700 disabled:opacity-50"
                            onClick={saveBulk}
                            disabled={loading || dirtyCount === 0}
                        >
                            変更を保存{dirtyCount ? `（${dirtyCount}）` : ""}
                        </button>
                        <button
                            className="rounded border border-slate-300 px-3 py-2 text-sm hover:bg-slate-50 disabled:opacity-50"
                            onClick={() => setDirty({})}
                            disabled={dirtyCount === 0}
                        >
                            破棄
                        </button>
                    </div>
                </div>
            </div>

            {filterForm}

            {error ? (
                <div className="mb-3 rounded border border-red-200 bg-red-50 p-3 text-sm text-red-800">
                    {error}
                </div>
            ) : null}

            {saveMsg ? (
                <div className="mb-3 rounded border border-slate-200 bg-slate-50 p-3 text-sm text-slate-800">
                    {saveMsg}
                </div>
            ) : null}

            <h2 className="text-center text-xl font-semibold my-2">検索結果</h2>
            <div className="overflow-x-auto rounded border border-slate-200 bg-white">
                <table className="min-w-[1100px] w-full text-left text-sm">
                    <thead className="bg-slate-50 text-slate-700">
                        <tr>
                            <th className="w-[180px] px-3 py-2">書類名</th>
                            <th className="w-[300px] px-3 py-2">出願人</th>
                            <th className="w-[240px] px-3 py-2">整理番号/出願番号</th>
                            <th className="px-3 py-2">メタデータ</th>
                        </tr>
                    </thead>
                    <tbody>
                        {loading && !esRows.length ? (
                            <tr><td className="px-3 py-8 text-slate-500" colSpan={6}>読み込み中…</td></tr>
                        ) : null}

                        {!loading && !esRows.length ? (
                            <tr><td className="px-3 py-8 text-slate-500" colSpan={6}>検索結果がありません。</td></tr>
                        ) : null}

                        {esRows.map((r) => {
                            const meta = mergedMeta(r.source.docId ?? ""); // docIdがないのはおかしいけど一応
                            const isDirty = !!dirty[r.source.docId ?? ""];

                            return (
                                <tr key={r.source.docId} className={isDirty ? "bg-amber-50/40" : ""}>
                                    <td className="border-t border-slate-400 px-3 py-2 align-top">
                                        <div className="flex flex-col gap-1">
                                            <a
                                                className="text-cyan-600 underline decoration-slate-300 underline-offset-2 hover:decoration-slate-600"
                                                href={`/docs/${encodeURIComponent(r.source.docId ?? "")}`}
                                                target="_blank"
                                                rel="noreferrer"
                                            >
                                                {r.source.documentName || r.source.inventionTitle || r.source.docId}
                                            </a>
                                            {isDirty ? (
                                                <span className="inline-flex w-fit rounded bg-amber-100 px-2 py-0.5 text-xs text-amber-800">
                                                    未保存
                                                </span>
                                            ) : null}
                                        </div>
                                    </td>

                                    <td className="border-t border-slate-400 px-3 py-2 align-top">
                                        {r.source.applicants
                                            ? r.source.applicants
                                                .map((a, index) => (
                                                    <div key={index} className="line-clamp-3 text-slate-900">{a}</div>
                                                ))
                                            :
                                            <div>出願人なし{/*ありえないはず*/}</div>
                                        }
                                    </td>

                                    <td className="border-t border-slate-400 px-3 py-2 align-top">
                                        <div className="mt-1 text-xs text-slate-600">
                                            <div>
                                                {(r.source.law && r.source.applicationNumber) ? `出願番号: ${formatApplicationNumber(r.source.law, r.source.applicationNumber)}` : ""}
                                                {(r.source.law && r.source.internationalApplicationNumber) ? `出願番号: ${formatApplicationNumber(r.source.law, r.source.internationalApplicationNumber)}` : ""}
                                            </div>
                                            <div>
                                                {r.source.fileReferenceId ? `整理番号: ${r.source.fileReferenceId}` : ""}
                                            </div>
                                        </div>
                                    </td>

                                    <td className="border-t border-slate-400 px-3 py-2 align-top">
                                        <ChipEditor
                                            value={meta.assignees}
                                            suggestions={assigneeSuggestions}
                                            placeholder="担当者（Enter/ ,）"
                                            onChange={(next) => setField(r.source.docId ?? "", { assignees: next })}
                                        />
                                        <ChipEditor
                                            value={meta.tags}
                                            suggestions={tagSuggestions}
                                            placeholder="タグ（Enter/ ,）"
                                            onChange={(next) => setField(r.source.docId ?? "", { tags: next })}
                                        />
                                        <ChipEditor
                                            value={meta.extraNumbers}
                                            placeholder="整理番号（Enter/ ,）"
                                            onChange={(next) => setField(r.source.docId ?? "", { extraNumbers: next })}
                                        />
                                    </td>
                                </tr>
                            );
                        })}
                    </tbody>
                </table>
            </div>

            <div className="mt-4 flex items-center justify-between text-sm">
                <div className="text-slate-600">
                    {esData ? `${esData.total} 件中 / ページ ${esData.page}（${esData.size}件）` : "—"}
                </div>

                <div className="flex items-center gap-2">
                    <button
                        className="rounded border border-slate-300 px-3 py-1.5 hover:bg-slate-50 disabled:opacity-50"
                        onClick={() => setPage((p) => Math.max(1, p - 1))}
                        disabled={page <= 1 || loading}
                    >
                        前へ
                    </button>
                    <span className="text-slate-700">{page} / {totalPages}</span>
                    <button
                        className="rounded border border-slate-300 px-3 py-1.5 hover:bg-slate-50 disabled:opacity-50"
                        onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
                        disabled={page >= totalPages || loading}
                    >
                        次へ
                    </button>
                </div>
            </div>
        </div>
    );
}