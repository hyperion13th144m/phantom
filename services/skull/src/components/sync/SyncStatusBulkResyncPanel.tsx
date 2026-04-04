"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";

type SyncStatusBulkResyncPanelProps = {
    selectedDocIds: string[];
};

export default function SyncStatusBulkResyncPanel({
    selectedDocIds,
}: SyncStatusBulkResyncPanelProps) {
    const router = useRouter();
    const [pending, setPending] = useState(false);
    const [message, setMessage] = useState("");

    async function run(body: Record<string, unknown>) {
        setPending(true);
        setMessage("");

        try {
            const res = await fetch("/api/metadata/sync", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                },
                body: JSON.stringify(body),
            });

            const json = await res.json();

            if (!res.ok) {
                throw new Error(json?.error ?? "再同期に失敗しました");
            }

            setMessage(
                json.failed > 0
                    ? `${json.succeeded} 件成功, ${json.failed} 件失敗`
                    : `${json.succeeded} 件再同期しました。`,
            );

            router.refresh();
        } catch (error) {
            setMessage(
                error instanceof Error ? error.message : "再同期に失敗しました",
            );
        } finally {
            setPending(false);
        }
    }

    return (
        <div className="space-y-4 rounded-xl border bg-white p-4 shadow-sm">
            <div className="space-y-1">
                <h2 className="text-lg font-semibold">再同期</h2>
                <p className="text-sm text-gray-600">
                    選択した文書、または failed / pending 全体を再同期できます。
                </p>
            </div>

            <div className="flex flex-wrap gap-3">
                <button
                    type="button"
                    disabled={pending || selectedDocIds.length === 0}
                    onClick={() => run({ docIds: selectedDocIds })}
                    className="rounded-lg border px-4 py-2 text-sm font-medium hover:bg-gray-50 disabled:opacity-50"
                >
                    {pending ? "実行中..." : `選択 ${selectedDocIds.length} 件を再同期`}
                </button>

                <button
                    type="button"
                    disabled={pending}
                    onClick={() => run({ allFailed: true })}
                    className="rounded-lg border px-4 py-2 text-sm font-medium hover:bg-gray-50 disabled:opacity-50"
                >
                    failed を全件再同期
                </button>

                <button
                    type="button"
                    disabled={pending}
                    onClick={() => run({ allPending: true })}
                    className="rounded-lg border px-4 py-2 text-sm font-medium hover:bg-gray-50 disabled:opacity-50"
                >
                    pending を全件再同期
                </button>
            </div>

            {message ? <p className="text-sm text-gray-700">{message}</p> : null}
        </div>
    );
}