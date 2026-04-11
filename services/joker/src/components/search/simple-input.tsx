type Props = {
  value: string;
  onChange: (value: string) => void;
  onSubmit: () => void;
  size: number;
  onSizeChange: (size: number) => void;
  placeholder?: string;
};

function clampSize(value: number) {
  return Math.min(Math.max(value, 1), 100);
}

export default function SimpleInput({
  value,
  onChange,
  onSubmit,
  size,
  onSizeChange,
  placeholder = "キーワード",
}: Props) {
  return (
    <div className="mb-4 flex flex-col gap-3 lg:flex-row lg:items-center">
      <div className="flex-1">
        <input
          value={value}
          onChange={(e) => onChange(e.target.value)}
          onKeyDown={(e) => {
            if (e.key === "Enter") {
              onSubmit();
            }
          }}
          placeholder={placeholder}
          className="w-full rounded-xl border border-slate-300 px-4 py-3 text-sm text-slate-900 shadow-sm outline-none transition focus:border-blue-500 focus:ring-4 focus:ring-blue-100"
        />
      </div>
      <div className="flex gap-3 sm:justify-end lg:flex-none">
        <select
          value={size}
          onChange={(e) => onSizeChange(clampSize(Number(e.target.value)))}
          className="rounded-xl border border-slate-300 bg-white px-3 py-3 text-sm text-slate-700 shadow-sm outline-none transition focus:border-blue-500 focus:ring-4 focus:ring-blue-100"
          title="表示件数"
        >
          {[10, 20, 50, 100].map((pageSize) => (
            <option key={pageSize} value={pageSize}>
              {pageSize}/page
            </option>
          ))}
        </select>
        <button
          onClick={onSubmit}
          className="rounded-xl bg-slate-900 px-5 py-3 text-sm font-semibold text-white transition hover:bg-slate-700"
        >
          検索
        </button>
      </div>
    </div>
  );
}
