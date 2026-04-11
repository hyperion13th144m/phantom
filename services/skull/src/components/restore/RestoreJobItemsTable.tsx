import Link from "next/link";
import type { RestoreJobItemRecord, RestoreJobRecord } from "@/lib/types/restore";

type Props = {
    job: RestoreJobRecord;
    items: RestoreJobItemRecord[];
};

export default function RestoreJobItemsTable({ job, items }: Props) {
    return (
        <div className="space-y-4">
            <div className="rounded-xl border bg-white p-4 shadow-sm space-y-2">
                <div className="text-sm"><span className="font-medium">jobId:</span> {job.id}</div>
                <div className="text-sm"><span className="font-medium">status:</span> {job.status}</div>
                <div className="text-sm"><span className="font-medium">target:</span> {job.targetMode}</div>
                <div className="text-sm"><span className="font-medium">request:</span></div>
                <pre className="rounded-lg bg-gray-50 p-3 text-xs overflow-x-auto">{job.requestJson}</pre>
            </div>

            <div className="overflow-x-auto rounded-xl border bg-white shadow-sm">
                <table className="min-w-full border-collapse text-sm">
                    <thead className="bg-gray-50">
                        <tr className="text-left">
                            <th className="border-b px-4 py-3">docId</th>
                            <th className="border-b px-4 py-3">ok</th>
                            <th className="border-b px-4 py-3">error</th>
                            <th className="border-b px-4 py-3">操作</th>
                        </tr>
                    </thead>
                    <tbody>
                        {items.length === 0 ? (
                            <tr>
                                <td colSpan={4} className="px-4 py-8 text-center text-gray-500">
                                    item はありません。
                                </td>
                            </tr>
                        ) : (
                            items.map((item) => (
                                <tr key={item.id}>
                                    <td className="border-b px-4 py-3 font-mono text-xs">{item.docId}</td>
                                    <td className="border-b px-4 py-3">{item.ok ? "true" : "false"}</td>
                                    <td className="border-b px-4 py-3">
                                        <div className="max-w-lg whitespace-pre-wrap break-words text-xs text-red-800">
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