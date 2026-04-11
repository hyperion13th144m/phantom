"use client";

import { Suspense, useEffect, useMemo, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import {
  buildSearchParams,
  getInitialFilters,
  MAX_PAGE,
  parseSearchQuery,
  SearchForm,
  SearchResults,
  useSearch,
  type FilterParam,
  type SearchFilters,
  type SearchQuery,
} from "@/components/search";
import { clamp } from "@/lib/helpers";

type ContentProps = {
  initialQuery: SearchQuery;
};

type ActiveSearchFilter = {
  key: string;
  label: string;
  value: string;
};

const searchFilterLabels: Record<keyof SearchFilters, string> = {
  applicant: "出願人",
  inventor: "発明者",
  assignee: "担当者",
  tag: "タグ",
  documentName: "文書名",
  specialMentionMatterArticle: "特記事項",
  rejectionReasonArticle: "拒絶理由",
  priorityClaims: "優先権",
};

function getActiveSearchFilters(
  q: string,
  filters: SearchFilters,
): ActiveSearchFilter[] {
  const items: ActiveSearchFilter[] = [];

  if (q.trim()) {
    items.push({ key: "q", label: "キーワード", value: q.trim() });
  }

  (Object.entries(filters) as Array<[keyof SearchFilters, string]>).forEach(
    ([key, value]) => {
      if (value.trim()) {
        items.push({
          key,
          label: searchFilterLabels[key],
          value: value.trim(),
        });
      }
    },
  );

  return items;
}

function SearchPageSection({ initialQuery }: ContentProps) {
  const router = useRouter();
  const [q, setQ] = useState(initialQuery.q);
  const [size, setSize] = useState(initialQuery.size);
  const [filters, setFilters] = useState<SearchFilters>(
    getInitialFilters(initialQuery),
  );
  const [isDrawerOpen, setIsDrawerOpen] = useState(false);
  const { data, err, fetchSearch, loading } = useSearch();
  const activeFilters = useMemo(
    () => getActiveSearchFilters(q, filters),
    [q, filters],
  );

  useEffect(() => {
    fetchSearch(initialQuery);
  }, [fetchSearch, initialQuery]);

  function pushQuery(next: SearchQuery) {
    router.push(`/search?${buildSearchParams(next).toString()}`);
  }

  function submit() {
    pushQuery({ ...initialQuery, ...filters, q, size, page: 1 });
    setIsDrawerOpen(false);
  }

  function handleFilterChange(param: FilterParam, value: string) {
    const nextFilters = { ...filters, [param]: value };
    setFilters(nextFilters);
    pushQuery({ ...initialQuery, ...nextFilters, q, size, page: 1 });
    setIsDrawerOpen(false);
  }

  const totalPages = data ? Math.max(1, Math.ceil(data.total / data.size)) : 1;

  return (
    <div className="min-h-screen bg-slate-100 px-4 py-8">
      <div className="mx-auto max-w-6xl space-y-6">
        <div className="rounded-3xl bg-gray-100 px-6 py-8 text-black shadow-sm">
          <div className="max-w-3xl">
            <h1 className="mt-3 text-3xl font-semibold tracking-tight">
              全文検索
            </h1>
            <p className="mt-3 text-sm leading-6 text-black">
              キーワード検索に加えて、出願人、発明者、文書名、タグなどの集計結果から段階的に絞り込めます。
              ハイライトと図面サムネイルを見ながら関連文書をすばやく確認できます。
            </p>
          </div>
        </div>

        <SearchForm
          data={data}
          filters={filters}
          isDrawerOpen={isDrawerOpen}
          onCloseDrawer={() => setIsDrawerOpen(false)}
          onFilterChange={handleFilterChange}
          onOpenDrawer={() => setIsDrawerOpen(true)}
          onQueryChange={setQ}
          onSizeChange={setSize}
          onSubmit={submit}
          q={q}
          size={size}
        />

        {activeFilters.length > 0 && (
          <section className="rounded-2xl border border-slate-200 bg-white px-5 py-4 shadow-sm">
            <div className="flex flex-wrap items-start justify-between gap-3">
              <div>
                <div className="text-sm font-semibold text-slate-900">
                  現在の検索条件
                </div>
                <p className="mt-1 text-sm text-slate-600">
                  条件を保ったまま、集計からさらに絞り込みできます。
                </p>
              </div>
              <div className="rounded-full bg-slate-100 px-3 py-1 text-xs font-medium text-slate-600">
                {activeFilters.length} 条件
              </div>
            </div>
            <div className="mt-4 flex flex-wrap gap-2">
              {activeFilters.map((filter) => (
                <span
                  key={filter.key}
                  className="rounded-full border border-slate-200 bg-slate-50 px-3 py-1.5 text-xs font-medium text-slate-700"
                >
                  {filter.label}: {filter.value}
                </span>
              ))}
            </div>
          </section>
        )}

        <SearchResults
          data={data}
          err={err}
          keywords={initialQuery.q}
          loading={loading}
          onPageChange={(newPage) => {
            const clampedPage = clamp(
              newPage,
              1,
              Math.min(totalPages, MAX_PAGE),
            );
            pushQuery({
              ...initialQuery,
              page: clampedPage,
            });
          }}
          page={initialQuery.page}
          totalPages={totalPages}
        />
      </div>
    </div>
  );
}

function SearchPageContent() {
  const searchParams = useSearchParams();
  const searchKey = searchParams.toString();
  const initialQuery = parseSearchQuery(searchParams);

  return <SearchPageSection key={searchKey} initialQuery={initialQuery} />;
}

export default function SearchPage() {
  return (
    <Suspense
      fallback={
        <div className="mx-auto my-6 max-w-[980px] text-center">
          読み込み中...
        </div>
      }
    >
      <SearchPageContent />
    </Suspense>
  );
}
