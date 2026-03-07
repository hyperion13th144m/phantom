import cfg from "../generated/config/storage-config.json";

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
    return `${baseUrl}/${docId}`;
}

// 国内出願番号形式（例：2023001234）
const domestic_number_re = /^[0-9]{10}$/;

// pct 出願番号形式（例：PCTJP2023XXXXXX)
const pct_number_re = /^[A-Za-z]{2}[0-9]{4}[0-9]{6}$/;
export const formatApplicationNumber = (law: string, docNumber: string): string => {
    if (docNumber.match(domestic_number_re)) {
        const prefix = law === "patent" ? "特願" : "実願";
        const year = docNumber.substring(0, 4);
        const seq = docNumber.substring(4);
        return `${prefix}${year}-${seq}`;
    } else if (docNumber.match(pct_number_re)) {
        const country = docNumber.substring(0, 2);
        const year = docNumber.substring(2, 6);
        const seq = docNumber.substring(6);
        return `PCT/${country}${year}/${seq}`;
    } else {
        // その他の形式はそのまま返す
        return docNumber;
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
export function computePath(docId: string): string {
    if (cfg.mode === "prod") {
        return cfg.pattern
            .replace("{0}", docId[0])
            .replace("{1}", docId[1])
            .replace("{2}", docId[2])
            .replace("{3}", docId[3])
            .replace("{docId}", docId);
    } else {
        const devPath: { [key: string]: string } = cfg.devMap;
        if (!(docId in devPath)) {
            throw new Error(`docId ${docId} not found in devMap`);
        }
        return devPath[docId];
    }
}
