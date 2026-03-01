export function clamp(n: number, min: number, max: number) {
    return Math.max(min, Math.min(max, n));
}

// 画像URLを構築するヘルパー関数
export function buildImageUrl(docId: string, filename: string): string {
    const baseUrl = process.env.NEXT_PUBLIC_IMAGE_BASE_URL || "/images";
    return `${baseUrl}/${docId.substring(0, 2)}/${docId.substring(2, 4)}/${docId}/images/${filename}`;
}

export function buildDocUrl(docId: string): string {
    const baseUrl = process.env.NEXT_PUBLIC_DOCUMENT_BASE_URL || "/docs";
    return `${baseUrl}/${docId.substring(0, 2)}/${docId.substring(2, 4)}/${docId}`;
}

export function formatApplicationNumber(law: string, appNum: string): string {
    // law に基づいて適切にフォーマットする（例: 特許、実用新案、意匠、商標など）
    // ここでは単純に law と appNum を結合する例を示します
    if (law === "patent" && appNum.match(/^\d{10}$/)) {
        return `特願${appNum.substring(0, 4)}-${appNum.substring(4)}号`;
    } else if (law === "utilityModel" && appNum.match(/^\d{10}$/)) {
        return `実願${appNum.substring(0, 4)}-${appNum.substring(4)}号`;
    } else {
        return appNum;
    }
}

export function formatDate(dateStr: string | number): string {
    // dateStr は UTC ミリ秒 の epoch time 形式
    if (typeof dateStr === "number") {
        const date = new Date(dateStr);
        if (isNaN(date.getTime())) return String(dateStr); // 無効な日付の場合は元の文字列を返す
        const month = (date.getMonth() + 1).toString().padStart(2, "0"); // 月は0-11なので+1する
        const day = date.getDate().toString().padStart(2, "0"); // 日を2桁にする
        return `${date.getFullYear()}年${month}月${day}日`;
    } else if (typeof dateStr === "string") {
        const timestamp = Number(dateStr);
        if (!isNaN(timestamp)) {
            const date = new Date(timestamp);
            if (!isNaN(date.getTime())) {
                const month = (date.getMonth() + 1).toString().padStart(2, "0");
                const day = date.getDate().toString().padStart(2, "0");
                return `${date.getFullYear()}年${month}月${day}日`;
            }
        }
        // 文字列が日付形式であればそのまま返す
        return dateStr;
    } else {
        return String(dateStr);
    }
}

export const dateTag = (documentCode: string | undefined) => {
    if (documentCode === "A163") {
        return "出願日";
    } else if (["A101", "A102", "A1131", "A130"].includes(documentCode ?? "")) {
        return "発送日";
    } else {
        return "提出日";

    }
}
