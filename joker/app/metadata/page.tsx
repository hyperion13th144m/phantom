"use client";

import React, { useEffect, useMemo, useState } from "react";

type EsRow = {
    docId: string;
    inventionTitle: string;
    applicants: string;
    inventors: string;
    appNumber: string;
    fileReferenceId: string;
};

type EsList = {
    page: number;
    size: number;
    total: number;
    rows: EsRow[];
};

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
    const [q, setQ] = useState("");
    const [page, setPage] = useState(1);
    const [size] = useState(25);

    const [loading, setLoading] = useState(false);
    const [esData, setEsData] = useState<EsList | null>(null);
    const [metaById, setMetaById] = useState<Record<string, Meta>>({});
    const [error, setError] = useState<string | null>(null);
    const [saveMsg, setSaveMsg] = useState<string | null>(null);

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
            const params = new URLSearchParams();
            params.set("page", String(page));
            params.set("size", String(size));
            if (q.trim()) params.set("q", q.trim());

            const res = await fetch(`/api/docs/search?${params.toString()}`, { cache: "no-store" });
            if (!res.ok) throw new Error(`GET /api/docs/search failed: ${res.status}`);
            const json = (await res.json()) as EsList;
            setEsData(json);

            const docIds = json.rows.map(r => r.docId);
            await fetchMetaByIds(docIds);

            // 検索条件が変わったら dirty は破棄する方が事故が少ない（おすすめ）
            setDirty({});
        } catch (e: any) {
            setError(e?.message ?? String(e));
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => { fetchEsAndMeta(); /* eslint-disable-next-line */ }, [page]);

    const esRows = esData?.rows ?? [];

    // 候補は「現在ページのメタ＋dirty」から簡易生成（必要なら専用APIに）
    const tagSuggestions = useMemo(() => {
        const s = new Set<string>();
        for (const r of esRows) (metaById[r.docId]?.tags ?? []).forEach(t => s.add(t));
        return Array.from(s).slice(0, 200);
    }, [esRows, metaById]);

    const assigneeSuggestions = useMemo(() => {
        const s = new Set<string>();
        for (const r of esRows) (metaById[r.docId]?.assignees ?? []).forEach(t => s.add(t));
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
            const docIds = esRows.map(r => r.docId);
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

    return (
        <div className="mx-auto max-w-7xl p-6">
            <div className="mb-4 flex flex-col gap-3 sm:flex-row sm:items-end sm:justify-between">
                <div>
                    <h1 className="text-xl font-semibold">検索結果にメタデータを付与</h1>
                    <p className="text-sm text-slate-600">
                        Elasticsearchの検索結果（docId）に対して、担当者・タグ・整理番号を編集し保存します。
                    </p>
                </div>

                <div className="flex flex-col gap-2 sm:flex-row sm:items-center">
                    <div className="flex items-center gap-2">
                        <input
                            className="w-80 rounded border border-slate-300 px-3 py-2 text-sm outline-none focus:border-slate-500"
                            placeholder="全文検索（タイトル/請求項/要約など）"
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

            <div className="overflow-x-auto rounded border border-slate-200 bg-white">
                <table className="min-w-[1400px] w-full text-left text-sm">
                    <thead className="bg-slate-50 text-slate-700">
                        <tr>
                            <th className="w-[260px] px-3 py-2">docId</th>
                            <th className="w-[420px] px-3 py-2">発明の名称</th>
                            <th className="w-[260px] px-3 py-2">出願人</th>
                            <th className="px-3 py-2">assignees</th>
                            <th className="px-3 py-2">tags</th>
                            <th className="px-3 py-2">extraNumbers</th>
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
                            const meta = mergedMeta(r.docId);
                            const isDirty = !!dirty[r.docId];

                            return (
                                <tr key={r.docId} className={isDirty ? "bg-amber-50/40" : ""}>
                                    <td className="border-t border-slate-100 px-3 py-2 align-top">
                                        <div className="flex flex-col gap-1">
                                            <a
                                                className="text-slate-900 underline decoration-slate-300 underline-offset-2 hover:decoration-slate-600"
                                                href={`/docs/${encodeURIComponent(r.docId)}`}
                                                target="_blank"
                                                rel="noreferrer"
                                            >
                                                {r.docId}
                                            </a>
                                            {isDirty ? (
                                                <span className="inline-flex w-fit rounded bg-amber-100 px-2 py-0.5 text-xs text-amber-800">
                                                    未保存
                                                </span>
                                            ) : null}
                                        </div>
                                    </td>

                                    <td className="border-t border-slate-100 px-3 py-2 align-top">
                                        <div className="line-clamp-3 text-slate-900">{r.inventionTitle}</div>
                                        <div className="mt-1 text-xs text-slate-600">
                                            {r.appNumber ? `出願番号: ${r.appNumber}` : ""}{r.fileReferenceId ? ` / 整理: ${r.fileReferenceId}` : ""}
                                        </div>
                                    </td>

                                    <td className="border-t border-slate-100 px-3 py-2 align-top">
                                        <div className="line-clamp-3 text-slate-900">{r.applicants}</div>
                                    </td>

                                    <td className="border-t border-slate-100 px-3 py-2 align-top">
                                        <ChipEditor
                                            value={meta.assignees}
                                            suggestions={assigneeSuggestions}
                                            placeholder="担当者（Enter/ ,）"
                                            onChange={(next) => setField(r.docId, { assignees: next })}
                                        />
                                    </td>

                                    <td className="border-t border-slate-100 px-3 py-2 align-top">
                                        <ChipEditor
                                            value={meta.tags}
                                            suggestions={tagSuggestions}
                                            placeholder="タグ（Enter/ ,）"
                                            onChange={(next) => setField(r.docId, { tags: next })}
                                        />
                                    </td>

                                    <td className="border-t border-slate-100 px-3 py-2 align-top">
                                        <ChipEditor
                                            value={meta.extraNumbers}
                                            placeholder="整理番号（Enter/ ,）"
                                            onChange={(next) => setField(r.docId, { extraNumbers: next })}
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