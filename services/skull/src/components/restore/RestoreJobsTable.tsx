import Link from "next/link";
import type { RestoreJobRecord } from "@/lib/types/restore";

type RestoreJobsTableProps = {
    items: RestoreJobRecord[];
};

function statusLabel(status: RestoreJobRecord["status"]) {
    switch (status) {
        case "completed":
            return "bg-green-100 text-green-800 border-green-200";
        case "partial":
            return "bg-yellow-100 text-yellow-800 border-yellow-200";
        case "failed":
            return "bg-red-100 text-red-800 border-red-200";
        case "running":
            return "bg-blue-100 text-blue-800 border-blue-200";
        default:
            return "bg-gray-100 text-gray-800 border-gray-200";
    }
}

export default function RestoreJobsTable({ items }: RestoreJobsTableProps) {
    return (
        <div className="overflow-x-auto rounded-xl border bg-white shadow-sm">
            <table className="min-w-full border-collapse text-sm">
                <thead className="bg-gray-50">
                    <tr className="text-left">
                        <th className="border-b px-4 py-3">jobId</th>
                        <th className="border-b px-4 py-3">status</th>
                        <th className="border-b px-4 py-3">target</th>
                        <th className="border-b px-4 py-3">requested</th>
                        <th className="border-b px-4 py-3">succeeded</th>
                        <th className="border-b px-4 py-3">failed</th>
                        <th className="border-b px-4 py-3">started</th>
                        <th className="border-b px-4 py-3">finished</th>
                        <th className="border-b px-4 py-3">操作</th>
                    </tr>
                </thead>
                <tbody>
                    {items.length === 0 ? (
                        <tr>
                            <td colSpan={9} className="px-4 py-8 text-center text-gray-500">
                                restore履歴はありません。
                            </td>
                        </tr>
                    ) : (
                        items.map((item) => (
                            <tr key={item.id} className="align-top">
                                <td className="border-b px-4 py-3 font-mono text-xs">{item.id}</td>
                                <td className="border-b px-4 py-3">
                                    <span className={`inline-flex rounded-full border px-2 py-1 text-xs font-medium ${statusLabel(item.status)}`}>
                                        {item.status}
                                    </span>
                                </td>
                                <td className="border-b px-4 py-3">{item.targetMode}</td>
                                <td className="border-b px-4 py-3">{item.requestedCount}</td>
                                <td className="border-b px-4 py-3">{item.succeededCount}</td>
                                <td className="border-b px-4 py-3">{item.failedCount}</td>
                                <td className="border-b px-4 py-3">{item.startedAt}</td>
                                <td className="border-b px-4 py-3">{item.finishedAt ?? "—"}</td>
                                <td className="border-b px-4 py-3">
                                    <Link
                                        href={`${process.env.NEXT_PUBLIC_BASE_PATH}/restore-jobs/${item.id}`}
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
    );
}