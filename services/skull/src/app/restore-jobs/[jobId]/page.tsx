import Link from "next/link";
import RestoreJobItemsTable from "@/components/restore/RestoreJobItemsTable";
import type { RestoreJobItemRecord, RestoreJobRecord } from "@/lib/types/restore";

type PageProps = {
    params: Promise<{ jobId: string }>;
    searchParams: Promise<{ limit?: string; offset?: string }>;
};

type ApiResponse = {
    job: RestoreJobRecord;
    limit: number;
    offset: number;
    items: RestoreJobItemRecord[];
};

async function fetchJob(jobId: string, params: {
    limit: number;
    offset: number;
}): Promise<ApiResponse> {
    const baseUrl = process.env.NEXT_PUBLIC_APP_URL ?? "http://localhost:3000";
    const sp = new URLSearchParams({
        limit: String(params.limit),
        offset: String(params.offset),
    });

    const res = await fetch(
        `${baseUrl}/api/metadata/restore-jobs/${encodeURIComponent(jobId)}?${sp.toString()}`,
        { cache: "no-store" },
    );

    if (!res.ok) {
        throw new Error("Failed to load restore job detail");
    }

    return res.json();
}

export default async function RestoreJobDetailPage({ params, searchParams }: PageProps) {
    const { jobId } = await params;
    const sp = await searchParams;
    const limit = Math.min(Math.max(Number(sp.limit ?? "200"), 1), 1000);
    const offset = Math.max(Number(sp.offset ?? "0"), 0);

    const result = await fetchJob(jobId, { limit, offset });

    return (
        <main className="mx-auto max-w-7xl p-6 space-y-6">
            <div className="flex items-center justify-between">
                <div className="space-y-2">
                    <h1 className="text-2xl font-bold">restore job detail</h1>
                    <p className="text-sm text-gray-600">jobId: {jobId}</p>
                </div>

                <Link
                    href={`${process.env.NEXT_PUBLIC_BASE_PATH}/restore-jobs`}
                    className="rounded-lg border px-4 py-2 hover:bg-gray-50"
                >
                    履歴一覧へ
                </Link>
            </div>

            <RestoreJobItemsTable job={result.job} items={result.items} />
        </main>
    );
}