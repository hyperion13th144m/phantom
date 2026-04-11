"use client";

import { useMemo, useState } from "react";
import Link from "next/link";
import type { MetadataSyncStatusRecord } from "@/lib/types/sync";
import SyncStatusBadge from "./SyncStatusBadge";
import SyncStatusBulkResyncPanel from "./SyncStatusBulkResyncPanel";

type SyncStatusTableProps = {
    items: MetadataSyncStatusRecord[];
};

export default function SyncStatusTable({ items }: SyncStatusTableProps) {
    const [selected, setSelected] = useState<Record<string, boolean>>({});

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

    return (
        <div className="space-y-4">
            <SyncStatusBulkResyncPanel selectedDocIds={selectedDocIds} />

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
                            <th className="border-b px-4 py-3">docId</th>
                            <th className="border-b px-4 py-3">sync status</th>
                            <th className="border-b px-4 py-3">retry count</th>
                            <th className="border-b px-4 py-3">last attempted</th>
                            <th className="border-b px-4 py-3">last succeeded</th>
                            <th className="border-b px-4 py-3">updated</th>
                            <th className="border-b px-4 py-3">error</th>
                            <th className="border-b px-4 py-3">操作</th>
                        </tr>
                    </thead>
                    <tbody>
                        {items.length === 0 ? (
                            <tr>
                                <td colSpan={9} className="px-4 py-8 text-center text-gray-500">
                                    対象データはありません。
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

                                    <td className="border-b px-4 py-3 font-mono text-xs">
                                        {item.docId}
                                    </td>

                                    <td className="border-b px-4 py-3">
                                        <SyncStatusBadge syncStatus={item} />
                                    </td>

                                    <td className="border-b px-4 py-3">{item.retryCount}</td>

                                    <td className="border-b px-4 py-3">
                                        {item.lastAttemptedAt ?? "—"}
                                    </td>

                                    <td className="border-b px-4 py-3">
                                        {item.lastSucceededAt ?? "—"}
                                    </td>

                                    <td className="border-b px-4 py-3">{item.updatedAt}</td>

                                    <td className="border-b px-4 py-3">
                                        <div className="max-w-md whitespace-pre-wrap break-words text-xs text-red-800">
                                            {item.errorMessage || "—"}
                                        </div>
                                    </td>

                                    <td className="border-b px-4 py-3">
                                        <Link
                                            href={`${process.env.NEXT_PUBLIC_BASE_PATH}/docs/${encodeURIComponent(item.docId)}`}
                                            className="rounded border px-3 py-1 hover:bg-gray-50"
                                        >
                                            詳細
                                        </Link>
                                    </td>
                                </tr>
                            ))
                        )}
                    </tbody>
                </table>
            </div>
        </div>
    );
}