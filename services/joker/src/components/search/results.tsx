import type { ApiResponseSuccess } from "@/interfaces/search-results";
import ErrorMessage from "@/components/error-message";
import HitResults from "./hit-results";
import Pagination from "./pagination";

type Props = {
  data: ApiResponseSuccess | null;
  err: string | null;
  keywords: string;
  loading: boolean;
  onPageChange: (page: number) => void;
  page: number;
  totalPages: number;
};

function EmptyState() {
  return (
    <div className="rounded-3xl border border-dashed border-slate-300 bg-white px-6 py-12 text-center shadow-sm">
      <div className="mx-auto flex h-14 w-14 items-center justify-center rounded-2xl bg-slate-100 text-slate-500">
        0件
      </div>
      <h3 className="mt-5 text-lg font-semibold text-slate-900">
        条件に一致する文書は見つかりませんでした
      </h3>
      <p className="mx-auto mt-2 max-w-2xl text-sm leading-6 text-slate-600">
        キーワードや絞り込み条件を少し広げると見つかることがあります。
        文書名やタグの条件を外して再検索してみてください。
      </p>
    </div>
  );
}

export default function SearchResults({
  data,
  err,
  keywords,
  loading,
  onPageChange,
  page,
  totalPages,
}: Props) {
  return (
    <section className="space-y-4">
      <Pagination
        currentPage={page}
        totalPages={totalPages}
        loading={loading}
        totalItems={data?.total}
        onPageChange={onPageChange}
      />

      {err && <ErrorMessage err={err} />}

      {data && (
        <>
          <div className="rounded-2xl border border-slate-200 bg-slate-50 px-5 py-4 text-sm text-slate-700">
            {data.hits.length === 0 ? (
              <span>検索結果がありません</span>
            ) : (
              <span>
                <span className="font-semibold text-slate-900">{data.total}</span>
                件中、
                <span className="font-semibold text-slate-900">{data.hits.length}</span>
                件を表示しています
              </span>
            )}
          </div>

          {data.hits.length === 0 ? (
            <EmptyState />
          ) : (
            <div className="flex flex-col gap-4">
              {data.hits.map((hit) => (
                <div
                  key={hit.id}
                  className="rounded-3xl border border-slate-200 bg-white p-4 shadow-sm"
                >
                  <HitResults hitResult={hit} keywords={keywords} />
                </div>
              ))}
            </div>
          )}
        </>
      )}
    </section>
  );
}
