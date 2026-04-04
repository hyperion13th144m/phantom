type SearchFormProps = {
    initialQ: string;
    initialSize: number;
};

export default function SearchForm({
    initialQ,
    initialSize,
}: SearchFormProps) {
    return (
        <form
            action="/search"
            method="GET"
            className="rounded-xl border bg-white p-4 shadow-sm"
        >
            <div className="grid gap-4 md:grid-cols-[1fr_140px_120px]">
                <div className="space-y-2">
                    <label htmlFor="q" className="block text-sm font-medium">
                        キーワード
                    </label>
                    <input
                        id="q"
                        name="q"
                        defaultValue={initialQ}
                        placeholder="例: battery electrode"
                        className="w-full rounded-lg border px-3 py-2 outline-none focus:ring"
                    />
                </div>

                <div className="space-y-2">
                    <label htmlFor="size" className="block text-sm font-medium">
                        件数
                    </label>
                    <select
                        id="size"
                        name="size"
                        defaultValue={String(initialSize)}
                        className="w-full rounded-lg border px-3 py-2"
                    >
                        <option value="10">10</option>
                        <option value="20">20</option>
                        <option value="50">50</option>
                        <option value="100">100</option>
                    </select>
                </div>

                <div className="flex items-end">
                    <button
                        type="submit"
                        className="w-full rounded-lg border px-4 py-2 font-medium hover:bg-gray-50"
                    >
                        検索
                    </button>
                </div>
            </div>

            <input type="hidden" name="page" value="1" />
        </form>
    );
}