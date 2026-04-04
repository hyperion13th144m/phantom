import SearchForm from "@/components/search/SearchForm";
import SearchResultTableClient from "@/components/search/SearchResultTableClient";
import type { SearchResponse } from "@/lib/types/metadata";

type SearchPageProps = {
    searchParams: Promise<{
        q?: string;
        page?: string;
        size?: string;
    }>;
};

async function fetchSearch(params: {
    q: string;
    page: number;
    size: number;
}): Promise<SearchResponse> {
    const search = new URLSearchParams({
        q: params.q,
        page: String(params.page),
        size: String(params.size),
    });

    const baseUrl = process.env.NEXT_PUBLIC_APP_URL ?? "http://localhost:3000";

    const res = await fetch(`${baseUrl}/api/search?${search.toString()}`, {
        cache: "no-store",
    });

    if (!res.ok) {
        throw new Error("Failed to fetch search results");
    }

    return res.json();
}

export default async function SearchPage({ searchParams }: SearchPageProps) {
    const sp = await searchParams;
    const q = sp.q ?? "";
    const page = Math.max(Number(sp.page ?? "1"), 1);
    const size = Math.min(Math.max(Number(sp.size ?? "20"), 1), 100);

    const result = await fetchSearch({ q, page, size });

    return (
        <main className="mx-auto max-w-7xl p-6 space-y-6">
            <div className="space-y-2">
                <h1 className="text-2xl font-bold">skull search</h1>
                <p className="text-sm text-gray-600">
                    Elasticsearch を検索し、付加データを一覧確認・一括更新します。
                </p>
            </div>

            <SearchForm initialQ={q} initialSize={size} />

            <div className="text-sm text-gray-600">
                {result.total.toLocaleString()} 件中 {(page - 1) * size + 1}-
                {Math.min(page * size, result.total)} 件を表示
            </div>

            <SearchResultTableClient
                items={result.items}
                page={page}
                size={size}
                total={result.total}
                q={q}
            />
        </main>
    );
}