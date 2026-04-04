import Link from "next/link";
import type { SearchResultItem } from "@/lib/types/metadata";

type SearchResultTableProps = {
    items: SearchResultItem[];
    page: number;
    size: number;
    total: number;
    q: string;
};

function buildPageHref(params: {
    q: string;
    page: number;
    size: number;
}) {
    const sp = new URLSearchParams({
        q: params.q,
        page: String(params.page),
        size: String(params.size),
    });
    return `/search?${sp.toString()}`;
}

export default function SearchResultTable({
    items,
    page,
    size,
    total,
    q,
}: SearchResultTableProps) {
    const totalPages = Math.max(Math.ceil(total / size), 1);

    return (
        <div className="space-y-4">
            <div className="overflow-x-auto rounded-xl border bg-white shadow-sm">
                <table className="min-w-full border-collapse text-sm">
                    <thead className="bg-gray-50">
                        <tr className="text-left">
                            <th className="border-b px-4 py-3">docId</th>
                            <th className="border-b px-4 py-3">発明の名称</th>
                            <th className="border-b px-4 py-3">出願人</th>
                            <th className="border-b px-4 py-3">tags</th>
                            <th className="border-b px-4 py-3">assignees</th>
                            <th className="border-b px-4 py-3">checked</th>
                            <th className="border-b px-4 py-3">memo</th>
                            <th className="border-b px-4 py-3">操作</th>
                        </tr>
                    </thead>
                    <tbody>
                        {items.length === 0 ? (
                            <tr>
                                <td
                                    colSpan={8}
                                    className="px-4 py-8 text-center text-gray-500"
                                >
                                    該当する文書はありません。
                                </td>
                            </tr>
                        ) : (
                            items.map((item) => (
                                <tr key={item.docId} className="align-top">
                                    <td className="border-b px-4 py-3 font-mono text-xs">
                                        {item.docId}
                                    </td>

                                    <td className="border-b px-4 py-3">
                                        {item.inventionTitle ?? ""}
                                    </td>

                                    <td className="border-b px-4 py-3">
                                        {item.applicants?.join(", ") ?? ""}
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
                            href={buildPageHref({ q, page: page - 1, size })}
                            className="rounded border px-3 py-2 hover:bg-gray-50"
                        >
                            前へ
                        </Link>
                    ) : (
                        <span className="rounded border px-3 py-2 text-gray-400">
                            前へ
                        </span>
                    )}

                    {page < totalPages ? (
                        <Link
                            href={buildPageHref({ q, page: page + 1, size })}
                            className="rounded border px-3 py-2 hover:bg-gray-50"
                        >
                            次へ
                        </Link>
                    ) : (
                        <span className="rounded border px-3 py-2 text-gray-400">
                            次へ
                        </span>
                    )}
                </div>
            </div>
        </div>
    );
}