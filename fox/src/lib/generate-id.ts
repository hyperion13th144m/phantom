import crypto from "node:crypto";

/**
 * 発明者名など文字列から安定した Id を生成する
 * @example 山田 太郎 -> inv_a3f9c2e41b
 */
export function generateId(srcString: string): string {
    const normalized = normalizeString(srcString);

    const hash = crypto
        .createHash("sha256")
        .update(normalized)
        .digest("hex")
        .slice(0, 10); // ← 10〜12桁推奨

    return `inv_${hash}`;
}

/** 表記ゆれ対策 */
function normalizeString(srcString: string): string {
    return srcString
        .trim()
        .replace(/\s+/g, "")        // 空白除去（全角半角）
        .replace(/　/g, "")
        .normalize("NFKC");         // 全角/半角 正規化
}
