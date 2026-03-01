export function clamp(n: number, min: number, max: number) {
    return Math.max(min, Math.min(max, n));
}

// 画像URLを構築するヘルパー関数
export function buildImageUrl(docId: string, filename: string): string {
    const baseUrl = process.env.NEXT_PUBLIC_IMAGE_BASE_URL || "/images";
    return `${baseUrl}/${docId.substring(0, 2)}/${docId.substring(2, 4)}/${docId}/images/${filename}`;
}

export function formatApplicationNumber(law: string, appNum: string): string {
    // law に基づいて適切にフォーマットする（例: 特許、実用新案、意匠、商標など）
    // ここでは単純に law と appNum を結合する例を示します
    if (law === "patent" && appNum.match(/^\d{10}$/)) {
        return `特願${appNum.substring(0, 4)}-${appNum.substring(5)}号`;
    } else if (law === "utilityModel" && appNum.match(/^\d{10}$/)) {
        return `実願${appNum.substring(0, 4)}-${appNum.substring(5)}号`;
    } else {
        return appNum;
    }
}

export function formatDate(dateStr: string | number): string {
    // dateStr は UTC ミリ秒 の epoch time 形式
    if (typeof dateStr === "number") {
        const date = new Date(dateStr);
        if (isNaN(date.getTime())) return String(dateStr); // 無効な日付の場合は元の文字列を返す
        return date.toLocaleDateString("ja-JP");
    } else if (typeof dateStr === "string") {
        const timestamp = Number(dateStr);
        if (!isNaN(timestamp)) {
            const date = new Date(timestamp);
            if (!isNaN(date.getTime())) {
                return date.toLocaleDateString("ja-JP");
            }
        }
        // 文字列が日付形式であればそのまま返す
        return dateStr;
    } else {
        return String(dateStr);
    }
}
