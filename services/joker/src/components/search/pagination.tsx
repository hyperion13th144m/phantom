type Props = {
  currentPage: number;
  totalPages: number;
  loading: boolean;
  totalItems?: number;
  onPageChange: (page: number) => void;
};

export default function Pagination({
  currentPage,
  totalPages,
  loading,
  totalItems,
  onPageChange,
}: Props) {
  return (
    <div className="flex flex-col items-center gap-3 rounded-2xl border border-slate-200 bg-white px-4 py-4 shadow-sm sm:flex-row sm:justify-between">
      <button
        onClick={() => onPageChange(currentPage - 1)}
        disabled={currentPage <= 1 || loading}
        className="inline-flex min-w-[96px] items-center justify-center rounded-xl border border-slate-300 px-3 py-2 text-sm font-medium text-slate-700 transition hover:border-slate-400 hover:bg-slate-50 disabled:cursor-not-allowed disabled:opacity-40"
      >
        前へ
      </button>

      <div className="text-center text-sm text-slate-600">
        {loading
          ? "検索中…"
          : totalItems !== undefined
            ? `合計 ${totalItems} 件 | ${currentPage} / ${totalPages} ページ`
            : ""}
      </div>

      <button
        onClick={() => onPageChange(currentPage + 1)}
        disabled={currentPage >= totalPages || loading}
        className="inline-flex min-w-[96px] items-center justify-center rounded-xl border border-slate-300 px-3 py-2 text-sm font-medium text-slate-700 transition hover:border-slate-400 hover:bg-slate-50 disabled:cursor-not-allowed disabled:opacity-40"
      >
        次へ
      </button>
    </div>
  );
}
