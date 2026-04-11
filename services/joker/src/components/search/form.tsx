import type { ApiResponseSuccess } from "@/interfaces/search-results";
import SimpleInput from "./simple-input";
import {
  FILTERS,
  type FilterParam,
  type SearchFilters,
} from "./state";

type Props = {
  data: ApiResponseSuccess | null;
  filters: SearchFilters;
  isDrawerOpen: boolean;
  onCloseDrawer: () => void;
  onFilterChange: (param: FilterParam, value: string) => void;
  onOpenDrawer: () => void;
  onQueryChange: (value: string) => void;
  onSizeChange: (value: number) => void;
  onSubmit: () => void;
  q: string;
  size: number;
};

function FilterControls({
  data,
  filters,
  onFilterChange,
}: Pick<Props, "data" | "filters" | "onFilterChange">) {
  return (
    <div className="flex flex-wrap gap-4">
      {FILTERS.map((filter) => {
        const aggregation = data?.aggregations?.[filter.key];
        if (!aggregation || aggregation.length === 0) {
          return null;
        }

        return (
          <div key={filter.key} className="min-w-[220px] flex-1">
            <label className="mb-2 block text-sm font-medium text-slate-700">
              {filter.label}
            </label>
            <select
              value={filters[filter.param]}
              onChange={(e) => onFilterChange(filter.param, e.target.value)}
              className="w-full rounded-xl border border-slate-300 bg-white px-3 py-2.5 text-sm text-slate-900 shadow-sm outline-none transition focus:border-blue-500 focus:ring-4 focus:ring-blue-100"
            >
              <option value="">すべて</option>
              {aggregation.slice(0, 20).map((bucket) => (
                <option key={bucket.key} value={bucket.key}>
                  {bucket.key} ({bucket.doc_count})
                </option>
              ))}
            </select>
          </div>
        );
      })}
    </div>
  );
}

export default function SearchForm({
  data,
  filters,
  isDrawerOpen,
  onCloseDrawer,
  onFilterChange,
  onOpenDrawer,
  onQueryChange,
  onSizeChange,
  onSubmit,
  q,
  size,
}: Props) {
  return (
    <>
      <div className="sticky top-12 z-40 border-b border-slate-200 bg-white px-2 py-2 md:hidden">
        <button
          onClick={onOpenDrawer}
          className="w-full rounded-xl bg-slate-900 px-4 py-2.5 text-sm font-semibold text-white"
        >
          検索条件を開く
        </button>
      </div>

      <div className="sticky top-12 z-40 hidden rounded-3xl border border-slate-200 bg-white px-5 py-5 shadow-sm md:block">
        <SimpleInput
          value={q}
          onChange={onQueryChange}
          onSubmit={onSubmit}
          size={size}
          onSizeChange={onSizeChange}
        />
        <FilterControls
          data={data}
          filters={filters}
          onFilterChange={onFilterChange}
        />
      </div>

      {isDrawerOpen && (
        <div className="fixed inset-0 z-50 md:hidden">
          <button
            aria-label="ドロワーを閉じる"
            className="absolute inset-0 bg-black/40"
            onClick={onCloseDrawer}
          />
          <div className="absolute right-0 top-0 h-full w-[92%] max-w-md overflow-y-auto bg-white p-4 shadow-xl">
            <div className="mb-4 flex items-center justify-between">
              <h2 className="text-lg font-semibold text-slate-900">検索条件</h2>
              <button
                onClick={onCloseDrawer}
                className="rounded-xl border border-slate-300 px-3 py-1.5 text-sm text-slate-700"
              >
                閉じる
              </button>
            </div>
            <SimpleInput
              value={q}
              onChange={onQueryChange}
              onSubmit={onSubmit}
              size={size}
              onSizeChange={onSizeChange}
            />
            <FilterControls
              data={data}
              filters={filters}
              onFilterChange={onFilterChange}
            />
          </div>
        </div>
      )}
    </>
  );
}
