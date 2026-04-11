"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";

type RestoreMode = "all" | "docIds";

type RestorePanelProps = {
    defaultBatchSize?: number;
    defaultLimit?: number;
};

type RunState =
    | { type: "idle" }
    | { type: "success"; message: string }
    | { type: "error"; message: string };

function parseDocIds(value: string): string[] {
    return [...new Set(
        value
            .split(/[\n,]+/)
            .map((v) => v.trim())
            .filter(Boolean),
    )];
}

export default function RestorePanel({
    defaultBatchSize = 200,
    defaultLimit = 1000,
}: RestorePanelProps) {
    const router = useRouter();

    const [mode, setMode] = useState<RestoreMode>("all");
    const [docIdsText, setDocIdsText] = useState("");
    const [limitValue, setLimitValue] = useState(String(defaultLimit));
    const [offsetValue, setOffsetValue] = useState("0");
    const [batchSizeValue, setBatchSizeValue] = useState(String(defaultBatchSize));
    const [pending, setPending] = useState(false);
    const [state, setState] = useState<RunState>({ type: "idle" });

    async function onSubmit(e: React.FormEvent<HTMLFormElement>) {
        e.preventDefault();
        setPending(true);
        setState({ type: "idle" });

        try {
            const batchSize = Math.max(1, Math.min(Number(batchSizeValue || "200"), 1000));

            let body: Record<string, unknown>;

            if (mode === "all") {
                const limit = Math.max(1, Math.min(Number(limitValue || "1000"), 10000));
                const offset = Math.max(0, Number(offsetValue || "0"));

                body = {
                    all: true,
                    limit,
                    offset,
                    batchSize,
                };
            } else {
                const docIds = parseDocIds(docIdsText);

                if (docIds.length === 0) {
                    throw new Error("docIds を入力してください。");
                }

                body = {
                    docIds,
                    batchSize,
                };
            }

            const res = await fetch(`${process.env.NEXT_PUBLIC_BASE_PATH}/api/metadata/restore`, {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                },
                body: JSON.stringify(body),
            });

            const json = await res.json();

            if (!res.ok) {
                throw new Error(json?.error ?? "restore に失敗しました");
            }

            const baseMessage =
                json.failed > 0
                    ? `${json.succeeded} 件成功, ${json.failed} 件失敗`
                    : `${json.succeeded} 件リストアしました。`;

            const totalMessage =
                typeof json.totalAvailable === "number"
                    ? ` SQLite総件数: ${json.totalAvailable} 件`
                    : "";

            setState({
                type: json.failed > 0 ? "error" : "success",
                message: `${baseMessage}${totalMessage}`,
            });

            router.refresh();
        } catch (error) {
            setState({
                type: "error",
                message: error instanceof Error ? error.message : "restore に失敗しました",
            });
        } finally {
            setPending(false);
        }
    }

    return (
        <form
            onSubmit={onSubmit}
            className="space-y-4 rounded-xl border bg-white p-4 shadow-sm"
        >
            <div className="space-y-1">
                <h2 className="text-lg font-semibold">restore</h2>
                <p className="text-sm text-gray-600">
                    SQLite に保存された metadata を、sync_status に関係なく Elasticsearch に再投入します。
                </p>
                <div className="rounded-lg bg-yellow-50 p-3 text-sm text-yellow-900">
                    先に panther 側で元文書を Elasticsearch に再登録しておく前提です。
                </div>
            </div>

            <div className="flex flex-wrap gap-4">
                <label className="flex items-center gap-2 text-sm">
                    <input
                        type="radio"
                        name="restoreMode"
                        checked={mode === "all"}
                        onChange={() => setMode("all")}
                    />
                    全件または範囲で restore
                </label>

                <label className="flex items-center gap-2 text-sm">
                    <input
                        type="radio"
                        name="restoreMode"
                        checked={mode === "docIds"}
                        onChange={() => setMode("docIds")}
                    />
                    指定 docIds を restore
                </label>
            </div>

            {mode === "all" ? (
                <div className="grid gap-4 md:grid-cols-3">
                    <div className="space-y-2">
                        <label className="block text-sm font-medium">limit</label>
                        <input
                            value={limitValue}
                            onChange={(e) => setLimitValue(e.target.value)}
                            inputMode="numeric"
                            className="w-full rounded-lg border px-3 py-2 text-sm"
                            placeholder="1000"
                        />
                    </div>

                    <div className="space-y-2">
                        <label className="block text-sm font-medium">offset</label>
                        <input
                            value={offsetValue}
                            onChange={(e) => setOffsetValue(e.target.value)}
                            inputMode="numeric"
                            className="w-full rounded-lg border px-3 py-2 text-sm"
                            placeholder="0"
                        />
                    </div>

                    <div className="space-y-2">
                        <label className="block text-sm font-medium">batchSize</label>
                        <input
                            value={batchSizeValue}
                            onChange={(e) => setBatchSizeValue(e.target.value)}
                            inputMode="numeric"
                            className="w-full rounded-lg border px-3 py-2 text-sm"
                            placeholder="200"
                        />
                    </div>
                </div>
            ) : (
                <div className="grid gap-4 md:grid-cols-[1fr_220px]">
                    <div className="space-y-2">
                        <label className="block text-sm font-medium">docIds</label>
                        <textarea
                            value={docIdsText}
                            onChange={(e) => setDocIdsText(e.target.value)}
                            rows={6}
                            className="w-full rounded-lg border px-3 py-2 font-mono text-sm"
                            placeholder={"改行またはカンマ区切り\n例:\nJP-2024-123456\nJP-2024-234567"}
                        />
                    </div>

                    <div className="space-y-2">
                        <label className="block text-sm font-medium">batchSize</label>
                        <input
                            value={batchSizeValue}
                            onChange={(e) => setBatchSizeValue(e.target.value)}
                            inputMode="numeric"
                            className="w-full rounded-lg border px-3 py-2 text-sm"
                            placeholder="200"
                        />
                    </div>
                </div>
            )}

            <div className="flex items-center gap-3">
                <button
                    type="submit"
                    disabled={pending}
                    className="rounded-lg border px-4 py-2 font-medium hover:bg-gray-50 disabled:opacity-50"
                >
                    {pending ? "restore 実行中..." : "restore 実行"}
                </button>

                <a
                    href={`${process.env.NEXT_PUBLIC_BASE_PATH}/restore-jobs`}
                    className="rounded-lg border px-4 py-2 text-sm hover:bg-gray-50"
                >
                    restore履歴
                </a>

                {state.type === "success" ? (
                    <span className="text-sm text-green-700">{state.message}</span>
                ) : null}

                {state.type === "error" ? (
                    <span className="text-sm text-red-700">{state.message}</span>
                ) : null}
            </div>
        </form>
    );
}