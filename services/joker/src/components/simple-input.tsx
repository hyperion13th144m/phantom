type SimpleInputProps = {
    value: string;
    onChange: (value: string) => void;
    onSubmit: () => void;
    size: number;
    onSizeChange: (size: number) => void;
    placeholder?: string;
};

export default function SimpleInput({
    value,
    onChange,
    onSubmit,
    size,
    onSizeChange,
    placeholder = "キーワード"
}: SimpleInputProps) {
    const clamp = (n: number, min: number, max: number) => Math.min(Math.max(n, min), max);

    return (
        <div className="flex gap-8 items-center mb-4">
            <input
                value={value}
                onChange={(e) => onChange(e.target.value)}
                onKeyDown={(e) => {
                    if (e.key === "Enter") onSubmit();
                }}
                placeholder={placeholder}
                className="flex-1 border border-gray-300 rounded px-3 py-2"
            />
            <select
                value={size}
                onChange={(e) => onSizeChange(clamp(Number(e.target.value), 1, 100))}
                className="px-3 py-2 border border-gray-300 rounded"
                title="表示件数"
            >
                {[10, 20, 50, 100].map((n) => (
                    <option key={n} value={n}>
                        {n}/page
                    </option>
                ))}
            </select>
            <button
                onClick={onSubmit}
                className="px-4 py-2 rounded border border-gray-800 bg-gray-800 text-white cursor-pointer"
            >
                検索
            </button>
        </div>
    );
}
