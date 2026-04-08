import type { BibliographicItems } from "~/interfaces/generated/bibliographic-items";

// 国内出願番号形式（例：2023001234）
const domestic_number_re = /^[0-9]{10}$/;

// pct 出願番号形式（例：PCTJP2023XXXXXX)
const pct_number_re = /^[A-Za-z]{2}[0-9]{4}[0-9]{6}$/;

export const getBibliography = async (docId: string, origin: string) => {
    try {
        const res = await fetch(`${origin}/api/${docId}/bibliographic-items`);
        if (!res.ok) throw new Error(`API Error: ${res.status}`);
        const data: BibliographicItems = await res.json();

        const date = data.datetime ? formatDate(data.datetime) : null;

        return {
            ...data,
            date,
        } as BibliographicItems
    } catch (err) {
        console.error(err);
        return null;
    }
}

const formatDate = (dateStr: string): string => {
    if (dateStr.match(/^[0-9]{8}$/)) {
        const year = dateStr.substring(0, 4);
        const month = dateStr.substring(4, 6);
        const day = dateStr.substring(6, 8);
        return `${year}年 ${month.padStart(2, "0")}月 ${day.padStart(2, "0")}日`;
    } else {
        return dateStr;
    }
};

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

/** 表記ゆれ対策 */
function normalizeString(srcString: string): string {
    return srcString
        .trim()
        .replace(/\s+/g, "")        // 空白除去（全角半角）
        .replace(/　/g, "")
        .normalize("NFKC");         // 全角/半角 正規化
}
