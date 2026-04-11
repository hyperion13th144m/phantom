import SearchForm from "@/components/search/SearchForm";
import SearchResultTable from "@/components/search/SearchResultTable";
import type { SearchAggregations, SearchResponse } from "@/lib/types/metadata";

type SearchPageProps = {
    searchParams: Promise<{
        q?: string;
        page?: string;
        size?: string;
        applicants?: string;
        inventors?: string;
        law?: string;
        documentName?: string;
        tags?: string;
        assignees?: string;
    }>;
};

async function fetchSearch(params: {
    q: string;
    page: number;
    size: number;
    applicants?: string;
    inventors?: string;
    law?: string;
    documentName?: string;
    tags?: string;
    assignees?: string;
}): Promise<SearchResponse> {
    const search = new URLSearchParams({
        q: params.q,
        page: String(params.page),
        size: String(params.size),
    });
    if (params.applicants) search.set("applicants", params.applicants);
    if (params.inventors) search.set("inventors", params.inventors);
    if (params.law) search.set("law", params.law);
    if (params.documentName) search.set("documentName", params.documentName);
    if (params.tags) search.set("tags", params.tags);
    if (params.assignees) search.set("assignees", params.assignees);

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
    const applicants = sp.applicants ?? "";
    const inventors = sp.inventors ?? "";
    const law = sp.law ?? "";
    const documentName = sp.documentName ?? "";
    const tags = sp.tags ?? "";
    const assignees = sp.assignees ?? "";

    const result = await fetchSearch({ q, page, size, applicants, inventors, law, documentName, tags, assignees });

    return (
        <main className="mx-auto max-w-7xl p-6 space-y-6">
            <div className="space-y-2">
                <h1 className="text-2xl font-bold">メタデータ編集</h1>
                <p className="text-sm text-gray-600">
                    特許文書を検索し、付加データを一覧確認・一括更新します。
                </p>
            </div>

            <SearchForm
                initialQ={q}
                initialSize={size}
                initialApplicants={applicants}
                initialInventors={inventors}
                initialLaw={law}
                initialDocumentName={documentName}
                initialTags={tags}
                initialAssignees={assignees}
                aggregations={result.aggregations as SearchAggregations}
            />

            <div className="text-sm text-gray-600">
                {result.total.toLocaleString()} 件中 {(page - 1) * size + 1}-
                {Math.min(page * size, result.total)} 件を表示
            </div>

            <SearchResultTable
                items={result.items}
                page={page}
                size={size}
                total={result.total}
                q={q}
                applicants={applicants}
                inventors={inventors}
                law={law}
                documentName={documentName}
                tags={tags}
                assignees={assignees}
            />
        </main>
    );
}