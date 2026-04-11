"use client";

import { useState } from "react";

type BulkEditToolbarProps = {
    selectedDocIds: string[];
    onDone?: () => void;
};

type SaveState =
    | { type: "idle" }
    | { type: "success"; message: string }
    | { type: "error"; message: string };

function splitCommaOrNewline(value: string): string[] {
    return [...new Set(
        value
            .split(/[\n,]+/)
            .map((v) => v.trim())
            .filter(Boolean),
    )];
}

export default function BulkEditToolbar({
    selectedDocIds,
    onDone,
}: BulkEditToolbarProps) {
    const [tagsText, setTagsText] = useState("");
    const [assigneesText, setAssigneesText] = useState("");
    const [extraNumbersText, setExtraNumbersText] = useState("");
    const [memoAppend, setMemoAppend] = useState("");
    const [checkedMode, setCheckedMode] = useState<"" | "true" | "false">("");
    const [pending, setPending] = useState(false);
    const [saveState, setSaveState] = useState<SaveState>({ type: "idle" });

    async function onSubmit(e: React.FormEvent<HTMLFormElement>) {
        e.preventDefault();

        if (selectedDocIds.length === 0) {
            setSaveState({ type: "error", message: "対象文書を選択してください。" });
            return;
        }

        const patch: Record<string, unknown> = {};

        const tagsToAdd = splitCommaOrNewline(tagsText);
        const assigneesToAdd = splitCommaOrNewline(assigneesText);
        const extraNumbersToAdd = splitCommaOrNewline(extraNumbersText);

        if (tagsToAdd.length > 0) patch.tagsToAdd = tagsToAdd;
        if (assigneesToAdd.length > 0) patch.assigneesToAdd = assigneesToAdd;
        if (extraNumbersToAdd.length > 0) patch.extraNumbersToAdd = extraNumbersToAdd;
        if (memoAppend.trim()) patch.memoAppend = memoAppend.trim();
        if (checkedMode === "true") patch.checked = true;
        if (checkedMode === "false") patch.checked = false;

        if (Object.keys(patch).length === 0) {
            setSaveState({ type: "error", message: "更新内容を入力してください。" });
            return;
        }

        setPending(true);
        setSaveState({ type: "idle" });

        try {
            const res = await fetch(`${process.env.NEXT_PUBLIC_BASE_PATH}/api/metadata/bulk`, {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                },
                body: JSON.stringify({
                    docIds: selectedDocIds,
                    patch,
                }),
            });

            const json = await res.json();

            if (!res.ok) {
                throw new Error(json?.error ?? "一括更新に失敗しました");
            }

            setSaveState({
                type: json.failed === 0 ? "success" : "error",
                message:
                    json.failed === 0
                        ? `${json.succeeded} 件を更新しました。`
                        : `${json.succeeded} 件成功, ${json.failed} 件失敗しました。`,
            });

            if (json.failed === 0) {
                setTagsText("");
                setAssigneesText("");
                setExtraNumbersText("");
                setMemoAppend("");
                setCheckedMode("");
            }

            onDone?.();
        } catch (error) {
            setSaveState({
                type: "error",
                message:
                    error instanceof Error ? error.message : "一括更新に失敗しました",
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
            <div className="flex items-center justify-between gap-4">
                <div>
                    <h2 className="text-lg font-semibold">一括更新</h2>
                    <p className="text-sm text-gray-600">
                        選択中: {selectedDocIds.length} 件
                    </p>
                </div>

                <button
                    type="submit"
                    disabled={pending || selectedDocIds.length === 0}
                    className="rounded-lg border px-4 py-2 font-medium hover:bg-gray-50 disabled:opacity-50"
                >
                    {pending ? "更新中..." : "一括更新"}
                </button>
            </div>

            <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
                <div className="space-y-2">
                    <label className="block text-sm font-medium">タグを追加</label>
                    <textarea
                        value={tagsText}
                        onChange={(e) => setTagsText(e.target.value)}
                        rows={4}
                        className="w-full rounded-lg border px-3 py-2 text-sm"
                        placeholder={"カンマまたは改行区切り\n例: battery, electrode"}
                    />
                </div>

                <div className="space-y-2">
                    <label className="block text-sm font-medium">担当者を追加</label>
                    <textarea
                        value={assigneesText}
                        onChange={(e) => setAssigneesText(e.target.value)}
                        rows={4}
                        className="w-full rounded-lg border px-3 py-2 text-sm"
                        placeholder={"カンマまたは改行区切り\n例: Yamada, Suzuki"}
                    />
                </div>

                <div className="space-y-2">
                    <label className="block text-sm font-medium">整理番号を追加</label>
                    <textarea
                        value={extraNumbersText}
                        onChange={(e) => setExtraNumbersText(e.target.value)}
                        rows={4}
                        className="w-full rounded-lg border px-3 py-2 text-sm"
                        placeholder={"カンマまたは改行区切り\n例: AB12CD34"}
                    />
                </div>

                <div className="space-y-2">
                    <label className="block text-sm font-medium">メモに追記</label>
                    <textarea
                        value={memoAppend}
                        onChange={(e) => setMemoAppend(e.target.value)}
                        rows={4}
                        className="w-full rounded-lg border px-3 py-2 text-sm"
                        placeholder="各文書のメモ末尾に追記します"
                    />
                </div>

                <div className="space-y-2">
                    <label className="block text-sm font-medium">チェック状態</label>
                    <select
                        value={checkedMode}
                        onChange={(e) =>
                            setCheckedMode(e.target.value as "" | "true" | "false")
                        }
                        className="w-full rounded-lg border px-3 py-2 text-sm"
                    >
                        <option value="">変更しない</option>
                        <option value="true">true にする</option>
                        <option value="false">false にする</option>
                    </select>
                </div>
            </div>

            {saveState.type === "success" ? (
                <p className="text-sm text-green-700">{saveState.message}</p>
            ) : null}

            {saveState.type === "error" ? (
                <p className="text-sm text-red-700">{saveState.message}</p>
            ) : null}
        </form>
    );
}