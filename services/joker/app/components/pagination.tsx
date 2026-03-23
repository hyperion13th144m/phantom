type PaginationProps = {
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
    onPageChange
}: PaginationProps) {
    return (
        <div className="flex justify-center gap-8 mb-2">
            <button
                onClick={() => onPageChange(currentPage - 1)}
                disabled={currentPage <= 1 || loading}
                className="px-3 py-2 rounded-lg border border-gray-300"
            >
                前へ
            </button>

            <div className="flex items-center justify-center min-w-[150px]">
                {loading
                    ? "検索中…"
                    : totalItems !== undefined
                        ? `合計 ${totalItems} 件 | ${currentPage} / ${totalPages} ページ`
                        : ""}
            </div>

            <button
                onClick={() => onPageChange(currentPage + 1)}
                disabled={currentPage >= totalPages || loading}
                className="px-3 py-2 rounded-lg border border-gray-300"
            >
                次へ
            </button>
        </div>
    );
}
