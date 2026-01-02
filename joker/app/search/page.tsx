"use client";

import { useEffect, useMemo, useState } from "react";
import { useSearchParams, useRouter } from "next/navigation";

type Hit = {
    id: string;
    score: number | null;
    source: {
        inventionTitle?: string;
        independentClaims?: string;
        dependentClaims?: string;
        embodiments?: string;
        abstract?: string;
        applicants?: string[];
        assignee?: string;
        tags?: string[];
    };
    highlight: Record<string, string[]>;
};

type ApiResponse = {
    page: number;
    size: number;
    total: number;
    hits: Hit[];
    error?: string;
    message?: string;
};

function clamp(n: number, min: number, max: number) {
    return Math.max(min, Math.min(max, n));
}

export default function SearchPage() {
    const router = useRouter();
    const sp = useSearchParams();

    const q0 = sp.get("q") ?? "";
    const page0 = Number(sp.get("page") ?? "1") || 1;
    const size0 = Number(sp.get("size") ?? "10") || 10;

    const [q, setQ] = useState(q0);
    const [page, setPage] = useState(clamp(page0, 1, 100000));
    const [size, setSize] = useState(clamp(size0, 1, 100));
    const [loading, setLoading] = useState(false);
    const [data, setData] = useState<ApiResponse | null>(null);
    const [err, setErr] = useState<string | null>(null);

    // URL同期（入力確定時に反映）
    const url = useMemo(() => {
        const p = new URLSearchParams();
        if (q.trim()) p.set("q", q.trim());
        p.set("page", String(page));
        p.set("size", String(size));
        return `/search?${p.toString()}`;
    }, [q, page, size]);

    useEffect(() => {
        // 初期値がURL由来なので、URLが変わったら入力も追随させる
        setQ(q0);
        setPage(clamp(page0, 1, 100000));
        setSize(clamp(size0, 1, 100));
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [q0, page0, size0]);

    async function fetchSearch(params: { q: string; page: number; size: number }) {
        const usp = new URLSearchParams();
        if (params.q.trim()) usp.set("q", params.q.trim());
        usp.set("page", String(params.page));
        usp.set("size", String(params.size));

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
        } catch (e: any) {
            setErr(e?.message ?? String(e));
            setData(null);
        } finally {
            setLoading(false);
        }
    }

    // URLクエリが変わったら検索実行
    useEffect(() => {
        fetchSearch({ q: q0, page: clamp(page0, 1, 100000), size: clamp(size0, 1, 100) });
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [q0, page0, size0]);

    function submit() {
        // 新しい検索は1ページ目から
        const p = new URLSearchParams();
        if (q.trim()) p.set("q", q.trim());
        p.set("page", "1");
        p.set("size", String(size));
        router.push(`/search?${p.toString()}`);
    }

    const totalPages = data ? Math.max(1, Math.ceil(data.total / data.size)) : 1;

    return (
        <div style={{ maxWidth: 980, margin: "24px auto", padding: "0 16px", fontFamily: "system-ui" }}>
            <h1 style={{ fontSize: 22, fontWeight: 700, marginBottom: 12 }}>Patent Search</h1>

            <div style={{ display: "flex", gap: 8, alignItems: "center", marginBottom: 16 }}>
                <input
                    value={q}
                    onChange={(e) => setQ(e.target.value)}
                    onKeyDown={(e) => {
                        if (e.key === "Enter") submit();
                    }}
                    placeholder="キーワード（例：電力変換, SiC, 寿命…）"
                    style={{
                        flex: 1,
                        padding: "10px 12px",
                        border: "1px solid #ccc",
                        borderRadius: 8,
                    }}
                />
                <select
                    value={size}
                    onChange={(e) => setSize(clamp(Number(e.target.value), 1, 100))}
                    style={{ padding: "10px 12px", border: "1px solid #ccc", borderRadius: 8 }}
                    title="表示件数"
                >
                    {[10, 20, 50, 100].map((n) => (
                        <option key={n} value={n}>
                            {n}/page
                        </option>
                    ))}
                </select>
                <button
                    onClick={submit}
                    style={{
                        padding: "10px 14px",
                        borderRadius: 8,
                        border: "1px solid #222",
                        background: "#222",
                        color: "#fff",
                        cursor: "pointer",
                    }}
                >
                    検索
                </button>
            </div>

            <div style={{ display: "flex", gap: 8, alignItems: "center", marginBottom: 10 }}>
                <button
                    onClick={() => {
                        const newPage = clamp(page - 1, 1, totalPages);
                        router.push(`/search?q=${encodeURIComponent(q0)}&page=${newPage}&size=${size0}`);
                    }}
                    disabled={page <= 1 || loading}
                    style={{ padding: "8px 10px", borderRadius: 8, border: "1px solid #ccc" }}
                >
                    前へ
                </button>

                <div style={{ fontSize: 13 }}>
                    {loading ? "検索中…" : data ? `合計 ${data.total} 件 / ${page} / ${totalPages} ページ` : ""}
                </div>

                <button
                    onClick={() => {
                        const newPage = clamp(page + 1, 1, totalPages);
                        router.push(`/search?q=${encodeURIComponent(q0)}&page=${newPage}&size=${size0}`);
                    }}
                    disabled={page >= totalPages || loading}
                    style={{ padding: "8px 10px", borderRadius: 8, border: "1px solid #ccc" }}
                >
                    次へ
                </button>
            </div>

            {err && (
                <div style={{ background: "#ffecec", border: "1px solid #ffb5b5", padding: 12, borderRadius: 8 }}>
                    <div style={{ fontWeight: 700, marginBottom: 6 }}>エラー</div>
                    <div style={{ whiteSpace: "pre-wrap" }}>{err}</div>
                </div>
            )}

            {data && (
                <div style={{ display: "flex", flexDirection: "column", gap: 10, marginTop: 12 }}>
                    {data.hits.map((h) => (
                        <div key={h.id} style={{ border: "1px solid #ddd", borderRadius: 12, padding: 12 }}>
                            <div style={{ fontWeight: 800, fontSize: 16, marginBottom: 6 }}>
                                {h.source.inventionTitle ?? "(no title)"}{" "}
                                <a href={`http://192.168.11.250:8080/docs/${h.id}?q=${encodeURIComponent(q0)}`} target="_blank" rel="noopener noreferrer" style={{ textDecoration: "none", marginLeft: 8, fontSize: 12 }}>
                                    <span style={{ fontWeight: 400, fontSize: 12, color: "#666" }}>
                                        id={h.id} {h.score != null ? `score=${h.score.toFixed(2)}` : ""}
                                    </span>
                                </a>
                            </div>

                            {/* ハイライトがあれば優先表示 */}
                            {Object.keys(h.highlight || {}).length > 0 && (
                                <div style={{ fontSize: 13, lineHeight: 1.6 }}>
                                    {Object.entries(h.highlight).slice(0, 3).map(([field, frags]) => (
                                        <div key={field} style={{ marginBottom: 4 }}>
                                            <span style={{ color: "#666" }}>{field}:</span>{" "}
                                            <span
                                                dangerouslySetInnerHTML={{
                                                    __html: frags.join(" … "),
                                                }}
                                            />
                                        </div>
                                    ))}
                                </div>
                            )}

                            {/* メタ情報 */}
                            <div style={{ fontSize: 13, marginTop: 8, color: "#333" }}>
                                <div>出願人: {(h.source.applicants ?? []).join(", ") || "-"}</div>
                                <div>担当者: {h.source.assignee ?? "-"}</div>
                                <div>タグ: {(h.source.tags ?? []).join(", ") || "-"}</div>
                            </div>
                        </div>
                    ))}

                    {data.hits.length === 0 && (
                        <div style={{ color: "#666", padding: 12, border: "1px dashed #ccc", borderRadius: 12 }}>
                            ヒットがありませんでした。
                        </div>
                    )}
                </div>
            )}
        </div>
    );
}
