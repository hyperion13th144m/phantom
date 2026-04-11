"use client";

import { useState } from "react";
import type { MetadataRecord } from "@/lib/types/metadata";
import SaveButton from "./SaveButton";

type MetadataEditorProps = {
    docId: string;
    initialMetadata: MetadataRecord | null;
};

type SaveState =
    | { type: "idle" }
    | { type: "success"; message: string }
    | { type: "error"; message: string };

function arrayToTextarea(value: string[] | undefined): string {
    return (value ?? []).join("\n");
}

function textareaToArray(value: string): string[] {
    return [...new Set(
        value
            .split(/\r?\n/)
            .map((v) => v.trim())
            .filter(Boolean),
    )];
}

export default function MetadataEditor({
    docId,
    initialMetadata,
}: MetadataEditorProps) {
    const [assigneesText, setAssigneesText] = useState(
        arrayToTextarea(initialMetadata?.assignees),
    );
    const [tagsText, setTagsText] = useState(
        arrayToTextarea(initialMetadata?.tags),
    );
    const [extraNumbersText, setExtraNumbersText] = useState(
        arrayToTextarea(initialMetadata?.extraNumbers),
    );
    const [memo, setMemo] = useState(initialMetadata?.memo ?? "");
    const [checked, setChecked] = useState(initialMetadata?.checked ?? false);
    const [pending, setPending] = useState(false);
    const [saveState, setSaveState] = useState<SaveState>({ type: "idle" });
    const [updatedAt, setUpdatedAt] = useState(initialMetadata?.updatedAt ?? "");

    async function onSubmit(e: React.FormEvent<HTMLFormElement>) {
        e.preventDefault();
        setPending(true);
        setSaveState({ type: "idle" });

        try {
            const body = {
                assignees: textareaToArray(assigneesText),
                tags: textareaToArray(tagsText),
                extraNumbers: textareaToArray(extraNumbersText),
                memo,
                checked,
            };

            const res = await fetch(`${process.env.NEXT_PUBLIC_BASE_PATH}/api/metadata/${encodeURIComponent(docId)}`, {
                method: "PUT",
                headers: {
                    "Content-Type": "application/json",
                },
                body: JSON.stringify(body),
            });

            const json = await res.json();

            if (!res.ok) {
                throw new Error(json?.error ?? "保存に失敗しました");
            }

            setUpdatedAt(json?.metadata?.updatedAt ?? "");
            setSaveState({ type: "success", message: "保存しました。" });
        } catch (error) {
            const message =
                error instanceof Error ? error.message : "保存に失敗しました";
            setSaveState({ type: "error", message });
        } finally {
            setPending(false);
        }
    }

    return (
        <form
            onSubmit={onSubmit}
            className="space-y-6 rounded-xl border bg-white p-6 shadow-sm"
        >
            <div className="space-y-1">
                <h2 className="text-xl font-semibold">メタデータ編集</h2>
                <p className="text-sm text-gray-600">docId: {docId}</p>
                {updatedAt ? (
                    <p className="text-xs text-gray-500">updatedAt: {updatedAt}</p>
                ) : null}
            </div>

            <div className="grid gap-6 md:grid-cols-2">
                <div className="space-y-2">
                    <label className="block text-sm font-medium">担当者</label>
                    <textarea
                        value={assigneesText}
                        onChange={(e) => setAssigneesText(e.target.value)}
                        rows={6}
                        className="w-full rounded-lg border px-3 py-2 font-mono text-sm"
                        placeholder={"1行に1件\n例:\nYamada\nSuzuki"}
                    />
                </div>

                <div className="space-y-2">
                    <label className="block text-sm font-medium">タグ</label>
                    <textarea
                        value={tagsText}
                        onChange={(e) => setTagsText(e.target.value)}
                        rows={6}
                        className="w-full rounded-lg border px-3 py-2 font-mono text-sm"
                        placeholder={"1行に1件\n例:\nbattery\nelectrode"}
                    />
                </div>

                <div className="space-y-2">
                    <label className="block text-sm font-medium">追加整理番号</label>
                    <textarea
                        value={extraNumbersText}
                        onChange={(e) => setExtraNumbersText(e.target.value)}
                        rows={6}
                        className="w-full rounded-lg border px-3 py-2 font-mono text-sm"
                        placeholder={"1行に1件\n例:\nAB12CD34\nZX98YU76"}
                    />
                </div>

                <div className="space-y-2">
                    <label className="block text-sm font-medium">メモ</label>
                    <textarea
                        value={memo}
                        onChange={(e) => setMemo(e.target.value)}
                        rows={6}
                        className="w-full rounded-lg border px-3 py-2 text-sm"
                        placeholder="自由記述メモ"
                    />
                </div>
            </div>

            <div className="flex items-center gap-3">
                <input
                    id="checked"
                    type="checkbox"
                    checked={checked}
                    onChange={(e) => setChecked(e.target.checked)}
                />
                <label htmlFor="checked" className="text-sm font-medium">
                    チェック済み
                </label>
            </div>

            <div className="flex items-center gap-3">
                <SaveButton pending={pending} />

                {saveState.type === "success" ? (
                    <span className="text-sm text-green-700">{saveState.message}</span>
                ) : null}

                {saveState.type === "error" ? (
                    <span className="text-sm text-red-700">{saveState.message}</span>
                ) : null}
            </div>
        </form>
    );
}