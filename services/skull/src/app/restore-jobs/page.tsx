import Link from "next/link";
import RestoreJobsTable from "@/components/restore/RestoreJobsTable";
import type { RestoreJobRecord } from "@/lib/types/restore";

type PageProps = {
    searchParams: Promise<{
        limit?: string;
        offset?: string;
    }>;
};

type ApiResponse = {
    limit: number;
    offset: number;
    items: RestoreJobRecord[];
};

async function fetchJobs(params: { limit: number; offset: number }): Promise<ApiResponse> {
    const baseUrl = process.env.NEXT_PUBLIC_APP_URL ?? "http://localhost:3000";
    const sp = new URLSearchParams({
        limit: String(params.limit),
        offset: String(params.offset),
    });

    const res = await fetch(`${baseUrl}/api/metadata/restore-jobs?${sp.toString()}`, {
        cache: "no-store",
    });

    if (!res.ok) {
        throw new Error("Failed to load restore jobs");
    }

    return res.json();
}

function buildHref(params: { limit: number; offset: number }) {
    const sp = new URLSearchParams({
        limit: String(params.limit),
        offset: String(params.offset),
    });
    return `${process.env.NEXT_PUBLIC_BASE_PATH}/restore-jobs?${sp.toString()}`;
}

export default async function RestoreJobsPage({ searchParams }: PageProps) {
    const sp = await searchParams;
    const limit = Math.min(Math.max(Number(sp.limit ?? "50"), 1), 200);
    const offset = Math.max(Number(sp.offset ?? "0"), 0);

    const result = await fetchJobs({ limit, offset });

    return (
        <main className="mx-auto max-w-7xl p-6 space-y-6">
            <div className="flex items-center justify-between">
                <div className="space-y-2">
                    <h1 className="text-2xl font-bold">restore jobs</h1>
                    <p className="text-sm text-gray-600">restore 実行履歴を確認します。</p>
                </div>

                <Link
                    href={`${process.env.NEXT_PUBLIC_BASE_PATH}/sync-status`}
                    className="rounded-lg border px-4 py-2 hover:bg-gray-50"
                >
                    sync statusへ
                </Link>
            </div>

            <RestoreJobsTable items={result.items} />

            <div className="flex items-center justify-between">
                <div className="text-sm text-gray-600">offset {offset}</div>

                <div className="flex gap-2">
                    {offset > 0 ? (
                        <Link
                            href={buildHref({ limit, offset: Math.max(offset - limit, 0) })}
                            className="rounded border px-3 py-2 hover:bg-gray-50"
                        >
                            前へ
                        </Link>
                    ) : (
                        <span className="rounded border px-3 py-2 text-gray-400">前へ</span>
                    )}

                    {result.items.length === limit ? (
                        <Link
                            href={buildHref({ limit, offset: offset + limit })}
                            className="rounded border px-3 py-2 hover:bg-gray-50"
                        >
                            次へ
                        </Link>
                    ) : (
                        <span className="rounded border px-3 py-2 text-gray-400">次へ</span>
                    )}
                </div>
            </div>
        </main>
    );
}