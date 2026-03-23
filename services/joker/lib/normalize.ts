export function splitCsvLike(input: unknown): string[] {
    if (Array.isArray(input)) {
        return input.map(String);
    }
    if (typeof input !== "string") return [];
    // カンマ/読点ゆれを統一
    const s = input.replace(/[，、]/g, ",");
    return s.split(",").map(v => v.trim()).filter(Boolean);
}

export function normalizeList(input: unknown, opts?: { max?: number }): string[] {
    const max = opts?.max ?? 50;
    const raw = splitCsvLike(input);

    // 連続空白の圧縮（必要なら）
    const cleaned = raw.map(v => v.replace(/\s+/g, " ").trim()).filter(Boolean);

    // 順序維持の重複除去（case-sensitive。必要ならtoLowerCaseで統一）
    const seen = new Set<string>();
    const uniq: string[] = [];
    for (const v of cleaned) {
        if (seen.has(v)) continue;
        seen.add(v);
        uniq.push(v);
        if (uniq.length >= max) break;
    }
    return uniq;
}

export function nowIso() {
    return new Date().toISOString();
}