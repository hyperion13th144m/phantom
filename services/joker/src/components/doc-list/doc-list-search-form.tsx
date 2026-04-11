import type { DocListQueryParams } from "@/lib/doc-list/schema";

type Props = {
  form: Required<DocListQueryParams>;
  hasActiveFilters: boolean;
  isCollapsed: boolean;
  loading: boolean;
  onChange: (key: keyof DocListQueryParams, value: string) => void;
  onReset: () => void;
  onSearch: () => void;
  onKeyDown: (event: React.KeyboardEvent) => void;
  onToggleCollapse: () => void;
};

const inputClassName =
  "w-full rounded-xl border border-slate-300 bg-white px-3 py-2.5 text-sm text-slate-900 shadow-sm outline-none transition focus:border-blue-500 focus:ring-4 focus:ring-blue-100";

export default function DocListSearchForm({
  form,
  hasActiveFilters,
  isCollapsed,
  loading,
  onChange,
  onReset,
  onSearch,
  onKeyDown,
  onToggleCollapse,
}: Props) {
  return (
    <section className="mb-8 overflow-hidden rounded-3xl border border-slate-200 bg-white shadow-sm">
      <div className="border-b border-slate-200 bg-slate-50 px-6 py-5">
        <div className="flex flex-wrap items-start justify-between gap-4">
          <div>
            <h2 className="text-lg font-semibold text-slate-900">検索条件</h2>
            <p className="mt-1 text-sm text-slate-600">
              項目内はスペース区切りで OR 条件、項目間は AND 条件で検索します。
            </p>
          </div>
          <div className="flex flex-wrap items-center gap-2">
            <div className="rounded-full bg-blue-50 px-3 py-1 text-xs font-medium text-blue-700">
              Enter キーでも検索できます
            </div>
            <button
              type="button"
              onClick={onToggleCollapse}
              className="inline-flex h-9 items-center justify-center rounded-full border border-slate-300 bg-white px-3 text-xs font-semibold text-slate-700 transition hover:border-slate-400 hover:bg-slate-100"
            >
              {isCollapsed ? "フォームを開く" : "フォームを閉じる"}
            </button>
          </div>
        </div>
      </div>

      {isCollapsed ? (
        <div className="flex flex-wrap items-center justify-between gap-3 px-6 py-4">
          <div className="text-sm text-slate-600">
            {hasActiveFilters
              ? "検索条件を保持したまま折りたたんでいます。必要なときだけ開いて調整できます。"
              : "検索条件は未入力です。フォームを開いて条件を指定してください。"}
          </div>
          <div className="rounded-full bg-slate-100 px-3 py-1 text-xs font-medium text-slate-600">
            {hasActiveFilters ? "条件あり" : "条件なし"}
          </div>
        </div>
      ) : (
        <div className="space-y-6 px-6 py-6">
          <div className="grid gap-5 md:grid-cols-2">
            <div>
              <label className="mb-2 block text-sm font-medium text-slate-700">
                発明者
              </label>
              <input
                type="text"
                value={form.inventors}
                onChange={(e) => onChange("inventors", e.target.value)}
                onKeyDown={onKeyDown}
                placeholder="例: 山田 太郎"
                className={inputClassName}
              />
            </div>

            <div>
              <label className="mb-2 block text-sm font-medium text-slate-700">
                出願人
              </label>
              <input
                type="text"
                value={form.applicants}
                onChange={(e) => onChange("applicants", e.target.value)}
                onKeyDown={onKeyDown}
                placeholder="例: OpenAI"
                className={inputClassName}
              />
            </div>
          </div>

          <div className="grid gap-5 md:grid-cols-2">
            <div>
              <label className="mb-2 block text-sm font-medium text-slate-700">
                出願番号
              </label>
              <input
                type="text"
                value={form.applicationNumber}
                onChange={(e) => onChange("applicationNumber", e.target.value)}
                onKeyDown={onKeyDown}
                placeholder="例: 2023-123456"
                className={inputClassName}
              />
            </div>

            <div>
              <label className="mb-2 block text-sm font-medium text-slate-700">
                整理番号
              </label>
              <input
                type="text"
                value={form.fileReferenceId}
                onChange={(e) => onChange("fileReferenceId", e.target.value)}
                onKeyDown={onKeyDown}
                placeholder="例: ABC-001"
                className={inputClassName}
              />
            </div>
          </div>

          <div className="grid gap-5 md:grid-cols-[minmax(0,1fr)_auto_auto] md:items-end">
            <div>
              <label className="mb-2 block text-sm font-medium text-slate-700">
                法律種別
              </label>
              <select
                value={form.law}
                onChange={(e) => onChange("law", e.target.value)}
                className={inputClassName}
              >
                <option value="">なし</option>
                <option value="patent">特許</option>
                <option value="utilityModel">実用新案</option>
              </select>
            </div>

            <button
              type="button"
              onClick={onReset}
              disabled={loading || !hasActiveFilters}
              className="inline-flex h-11 items-center justify-center rounded-xl border border-slate-300 bg-white px-4 text-sm font-semibold text-slate-700 transition hover:border-slate-400 hover:bg-slate-50 disabled:cursor-not-allowed disabled:border-slate-200 disabled:text-slate-400"
            >
              条件をクリア
            </button>

            <button
              type="button"
              onClick={onSearch}
              disabled={loading}
              className="inline-flex h-11 items-center justify-center rounded-xl bg-blue-600 px-4 text-sm font-semibold text-white transition hover:bg-blue-700 disabled:cursor-not-allowed disabled:bg-slate-300"
            >
              {loading ? "検索中..." : "この条件で検索"}
            </button>
          </div>
        </div>
      )}
    </section>
  );
}
