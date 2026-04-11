import Link from "next/link";
import SyncStatusTable from "@/components/sync/SyncStatusTable";
import RestorePanel from "@/components/restore/RestorePanel";
import type { MetadataSyncStatusRecord } from "@/lib/types/sync";

type SyncStatusPageProps = {
  searchParams: Promise<{
    statuses?: string;
    limit?: string;
    offset?: string;
  }>;
};

type SyncStatusApiResponse = {
  total: number;
  limit: number;
  offset: number;
  items: MetadataSyncStatusRecord[];
};

async function fetchSyncStatuses(params: {
  statuses: string;
  limit: number;
  offset: number;
}): Promise<SyncStatusApiResponse> {
  const baseUrl = process.env.NEXT_PUBLIC_APP_URL ?? "http://localhost:3000";
  const sp = new URLSearchParams({
    statuses: params.statuses,
    limit: String(params.limit),
    offset: String(params.offset),
  });

  const res = await fetch(
    `${baseUrl}/api/metadata/sync-status?${sp.toString()}`,
    {
      cache: "no-store",
    },
  );

  if (!res.ok) {
    throw new Error("Failed to load sync statuses");
  }

  return res.json();
}

function buildPageHref(params: {
  statuses: string;
  limit: number;
  offset: number;
}) {
  const sp = new URLSearchParams({
    statuses: params.statuses,
    limit: String(params.limit),
    offset: String(params.offset),
  });
  return `${process.env.NEXT_PUBLIC_BASE_PATH}/sync-status?${sp.toString()}`;
}

export default async function SyncStatusPage({
  searchParams,
}: SyncStatusPageProps) {
  const sp = await searchParams;
  const statuses = sp.statuses ?? "pending,failed";
  const limit = Math.min(Math.max(Number(sp.limit ?? "100"), 1), 500);
  const offset = Math.max(Number(sp.offset ?? "0"), 0);

  const result = await fetchSyncStatuses({
    statuses,
    limit,
    offset,
  });

  const prevOffset = Math.max(offset - limit, 0);
  const nextOffset = offset + limit;
  const showingFrom = result.total === 0 ? 0 : offset + 1;
  const showingTo = Math.min(offset + limit, result.total);

  return (
    <main className="mx-auto max-w-7xl p-6 space-y-6">
      <div className="flex items-center justify-between gap-4">
        <div className="space-y-2">
          <h1 className="text-2xl font-bold">メタデータの再同期/レストア</h1>
        </div>

        <div className="flex gap-2"></div>
      </div>

      <form
        action={`${process.env.NEXT_PUBLIC_BASE_PATH}/sync-status`}
        method="GET"
        className="rounded-xl border bg-white p-4 shadow-sm"
      >
        <div className="grid gap-4 md:grid-cols-[1fr_160px_120px]">
          <div className="space-y-2">
            <label className="block text-sm font-medium">statuses</label>
            <select
              name="statuses"
              defaultValue={statuses}
              className="w-full rounded-lg border px-3 py-2"
            >
              <option value="pending,failed">pending + failed</option>
              <option value="failed">failed only</option>
              <option value="pending">pending only</option>
              <option value="success">success only</option>
            </select>
          </div>

          <div className="space-y-2">
            <label className="block text-sm font-medium">limit</label>
            <select
              name="limit"
              defaultValue={String(limit)}
              className="w-full rounded-lg border px-3 py-2"
            >
              <option value="50">50</option>
              <option value="100">100</option>
              <option value="200">200</option>
              <option value="500">500</option>
            </select>
          </div>

          <div className="flex items-end">
            <button
              type="submit"
              className="w-full rounded-lg border px-4 py-2 font-medium hover:bg-gray-50"
            >
              絞り込み
            </button>
          </div>
        </div>

        <input type="hidden" name="offset" value="0" />
      </form>

      <div className="text-sm text-gray-600">
        {result.total.toLocaleString()} 件中 {showingFrom}-{showingTo} 件を表示
      </div>

      <SyncStatusTable items={result.items} />

      <div className="flex items-center justify-between">
        <div className="text-sm text-gray-600">offset {offset}</div>

        <div className="flex gap-2">
          {offset > 0 ? (
            <Link
              href={buildPageHref({
                statuses,
                limit,
                offset: prevOffset,
              })}
              className="rounded border px-3 py-2 hover:bg-gray-50"
            >
              前へ
            </Link>
          ) : (
            <span className="rounded border px-3 py-2 text-gray-400">前へ</span>
          )}

          {nextOffset < result.total ? (
            <Link
              href={buildPageHref({
                statuses,
                limit,
                offset: nextOffset,
              })}
              className="rounded border px-3 py-2 hover:bg-gray-50"
            >
              次へ
            </Link>
          ) : (
            <span className="rounded border px-3 py-2 text-gray-400">次へ</span>
          )}
        </div>
      </div>

      <hr className="border-t border-gray-200" />

      <RestorePanel defaultBatchSize={200} defaultLimit={1000} />
    </main>
  );
}
