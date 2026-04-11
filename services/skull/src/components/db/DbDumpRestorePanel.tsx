"use client";

import { useRef, useState } from "react";

type State =
    | { type: "idle" }
    | { type: "pending" }
    | { type: "success"; message: string }
    | { type: "error"; message: string };

export default function DbDumpRestorePanel() {
    const fileInputRef = useRef<HTMLInputElement>(null);
    const [dumpState, setDumpState] = useState<State>({ type: "idle" });
    const [restoreState, setRestoreState] = useState<State>({ type: "idle" });
    const [selectedFile, setSelectedFile] = useState<File | null>(null);

    async function handleDump() {
        setDumpState({ type: "pending" });
        try {
            const res = await fetch(
                `${process.env.NEXT_PUBLIC_BASE_PATH}/api/db/dump`,
            );
            if (!res.ok) {
                const json = await res.json().catch(() => ({}));
                setDumpState({
                    type: "error",
                    message: (json as { error?: string }).error ?? "ダンプに失敗しました",
                });
                return;
            }
            const blob = await res.blob();
            const url = URL.createObjectURL(blob);
            const a = document.createElement("a");
            a.href = url;
            a.download = "skull.db";
            a.click();
            URL.revokeObjectURL(url);
            setDumpState({ type: "success", message: "ダンプファイルをダウンロードしました" });
        } catch {
            setDumpState({ type: "error", message: "ダンプに失敗しました" });
        }
    }

    async function handleRestore() {
        if (!selectedFile) return;
        setRestoreState({ type: "pending" });
        try {
            const arrayBuffer = await selectedFile.arrayBuffer();
            const res = await fetch(
                `${process.env.NEXT_PUBLIC_BASE_PATH}/api/db/restore`,
                {
                    method: "POST",
                    headers: { "Content-Type": "application/octet-stream" },
                    body: arrayBuffer,
                },
            );
            const json = await res.json().catch(() => ({}));
            if (!res.ok) {
                setRestoreState({
                    type: "error",
                    message:
                        (json as { error?: string }).error ?? "リストアに失敗しました",
                });
                return;
            }
            setRestoreState({
                type: "success",
                message:
                    (json as { message?: string }).message ??
                    "リストアが完了しました",
            });
            setSelectedFile(null);
            if (fileInputRef.current) fileInputRef.current.value = "";
        } catch {
            setRestoreState({ type: "error", message: "リストアに失敗しました" });
        }
    }

    return (
        <div className="space-y-8">
            {/* Dump */}
            <section className="rounded-lg border p-6 space-y-4">
                <div>
                    <h2 className="text-lg font-semibold">ダンプ</h2>
                    <p className="text-sm text-gray-600 mt-1">
                        現在のデータベースをファイルとしてダウンロードします。
                    </p>
                </div>
                <button
                    type="button"
                    disabled={dumpState.type === "pending"}
                    onClick={handleDump}
                    className="rounded-lg bg-blue-600 px-4 py-2 text-white hover:bg-blue-700 disabled:opacity-50"
                >
                    {dumpState.type === "pending" ? "処理中..." : "ダンプ"}
                </button>
                {dumpState.type === "success" && (
                    <p className="text-sm text-green-700">{dumpState.message}</p>
                )}
                {dumpState.type === "error" && (
                    <p className="text-sm text-red-600">{dumpState.message}</p>
                )}
            </section>

            {/* Restore */}
            <section className="rounded-lg border p-6 space-y-4">
                <div>
                    <h2 className="text-lg font-semibold">リストア</h2>
                    <p className="text-sm text-gray-600 mt-1">
                        データベースファイルをアップロードしてデータベースを上書きします。
                        リストア後はサーバーの再起動が必要です。
                    </p>
                </div>
                <div className="space-y-3">
                    <input
                        ref={fileInputRef}
                        type="file"
                        accept=".db,application/octet-stream"
                        onChange={(e) =>
                            setSelectedFile(e.target.files?.[0] ?? null)
                        }
                        className="block text-sm text-gray-700"
                    />
                    <button
                        type="button"
                        disabled={
                            !selectedFile || restoreState.type === "pending"
                        }
                        onClick={handleRestore}
                        className="rounded-lg bg-amber-600 px-4 py-2 text-white hover:bg-amber-700 disabled:opacity-50"
                    >
                        {restoreState.type === "pending"
                            ? "処理中..."
                            : "リストア"}
                    </button>
                </div>
                {restoreState.type === "success" && (
                    <p className="text-sm text-green-700">{restoreState.message}</p>
                )}
                {restoreState.type === "error" && (
                    <p className="text-sm text-red-600">{restoreState.message}</p>
                )}
            </section>
        </div>
    );
}
