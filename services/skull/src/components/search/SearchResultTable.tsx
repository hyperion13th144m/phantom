"use client";

import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import type { SearchResultItem } from "@/lib/types/metadata";
import BulkEditToolbar from "./BulkEditToolbar";
import SyncStatusBadge from "@/components/sync/SyncStatusBadge";

type SearchResultTableProps = {
    items: SearchResultItem[];
    page: number;
    size: number;
    total: number;
    q: string;
    applicants?: string;
    inventors?: string;
    law?: string;
    documentName?: string;
    tags?: string;
    assignees?: string;
};

function buildPageHref(params: {
    q: string;
    page: number;
    size: number;
    applicants?: string;
    inventors?: string;
    law?: string;
    documentName?: string;
    tags?: string;
    assignees?: string;
}) {
    const sp = new URLSearchParams({
        q: params.q,
        page: String(params.page),
        size: String(params.size),
    });
    if (params.applicants) sp.set("applicants", params.applicants);
    if (params.inventors) sp.set("inventors", params.inventors);
    if (params.law) sp.set("law", params.law);
    if (params.documentName) sp.set("documentName", params.documentName);
    if (params.tags) sp.set("tags", params.tags);
    if (params.assignees) sp.set("assignees", params.assignees);
    return `/search?${sp.toString()}`;
}

export default function SearchResultTable({
    items,
    page,
    size,
    total,
    q,
    applicants,
    inventors,
    law,
    documentName,
    tags,
    assignees,
}: SearchResultTableProps) {
    const router = useRouter();
    const [selected, setSelected] = useState<Record<string, boolean>>({});

    const totalPages = Math.max(Math.ceil(total / size), 1);

    const selectedDocIds = useMemo(
        () => items.filter((item) => selected[item.docId]).map((item) => item.docId),
        [items, selected],
    );

    const allVisibleSelected =
        items.length > 0 && items.every((item) => selected[item.docId]);

    function toggleOne(docId: string, checked: boolean) {
        setSelected((prev) => ({
            ...prev,
            [docId]: checked,
        }));
    }

    function toggleAllVisible(checked: boolean) {
        setSelected((prev) => {
            const next = { ...prev };
            for (const item of items) {
                next[item.docId] = checked;
            }
            return next;
        });
    }

    function clearVisibleSelection() {
        setSelected((prev) => {
            const next = { ...prev };
            for (const item of items) {
                delete next[item.docId];
            }
            return next;
        });
    }

    return (
        <div className="space-y-4">
            <BulkEditToolbar
                selectedDocIds={selectedDocIds}
                onDone={() => {
                    clearVisibleSelection();
                    router.refresh();
                }}
            />

            <div className="overflow-x-auto rounded-xl border bg-white shadow-sm">
                <table className="min-w-full border-collapse text-sm">
                    <thead className="bg-gray-50">
                        <tr className="text-left">
                            <th className="border-b px-4 py-3">
                                <input
                                    type="checkbox"
                                    checked={allVisibleSelected}
                                    onChange={(e) => toggleAllVisible(e.target.checked)}
                                    aria-label="select all visible rows"
                                />
                            </th>
                            <th className="border-b px-4 py-3">書類名</th>
                            <th className="border-b px-4 py-3">出願人</th>
                            <th className="border-b px-4 py-3">タグ</th>
                            <th className="border-b px-4 py-3">担当者</th>
                            <th className="border-b px-4 py-3">チェック済み</th>
                            <th className="border-b px-4 py-3">同期</th>
                            <th className="border-b px-4 py-3">メモ</th>
                            <th className="border-b px-4 py-3">操作</th>
                        </tr>
                    </thead>

                    <tbody>
                        {items.length === 0 ? (
                            <tr>
                                <td colSpan={9} className="px-4 py-8 text-center text-gray-500">
                                    該当する文書はありません。
                                </td>
                            </tr>
                        ) : (
                            items.map((item) => (
                                <tr key={item.docId} className="align-top">
                                    <td className="border-b px-4 py-3">
                                        <input
                                            type="checkbox"
                                            checked={Boolean(selected[item.docId])}
                                            onChange={(e) => toggleOne(item.docId, e.target.checked)}
                                            aria-label={`select ${item.docId}`}
                                        />
                                    </td>

                                    <td className="border-b px-4 py-3 text-xs">
                                        {item.documentName ?? ""}
                                    </td>

                                    <td className="border-b px-4 py-3">
                                        {item.applicants?.map((applicant) => (
                                            <div key={applicant}>{applicant}</div>
                                        ))}
                                    </td>

                                    <td className="border-b px-4 py-3">
                                        {item.metadata?.tags?.join(", ") ??
                                            item.tags?.join(", ") ??
                                            ""}
                                    </td>

                                    <td className="border-b px-4 py-3">
                                        {item.metadata?.assignees?.join(", ") ?? ""}
                                    </td>

                                    <td className="border-b px-4 py-3">
                                        {item.metadata?.checked ? "✓" : ""}
                                    </td>

                                    <td className="border-b px-4 py-3">
                                        <SyncStatusBadge syncStatus={item.syncStatus} />
                                    </td>

                                    <td className="border-b px-4 py-3">
                                        <div className="max-w-xs whitespace-pre-wrap break-words">
                                            {item.metadata?.memo ?? ""}
                                        </div>
                                    </td>

                                    <td className="border-b px-4 py-3">
                                        <Link
                                            href={`/docs/${encodeURIComponent(item.docId)}`}
                                            className="rounded border px-3 py-1 hover:bg-gray-50"
                                        >
                                            編集
                                        </Link>
                                    </td>
                                </tr>
                            ))
                        )}
                    </tbody>
                </table>
            </div>

            <div className="flex items-center justify-between">
                <div className="text-sm text-gray-600">
                    page {page} / {totalPages}
                </div>

                <div className="flex gap-2">
                    {page > 1 ? (
                        <Link
                            href={buildPageHref({ q, page: page - 1, size, applicants, inventors, law, documentName, tags, assignees })}
                            className="rounded border px-3 py-2 hover:bg-gray-50"
                        >
                            前へ
                        </Link>
                    ) : (
                        <span className="rounded border px-3 py-2 text-gray-400">前へ</span>
                    )}

                    {page < totalPages ? (
                        <Link
                            href={buildPageHref({ q, page: page + 1, size, applicants, inventors, law, documentName, tags, assignees })}
                            className="rounded border px-3 py-2 hover:bg-gray-50"
                        >
                            次へ
                        </Link>
                    ) : (
                        <span className="rounded border px-3 py-2 text-gray-400">次へ</span>
                    )}
                </div>
            </div>
        </div>
    );
}