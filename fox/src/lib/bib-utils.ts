export function formatApplicationNumber(law: "patent" | "utilityModel", appNum: string): string {
    if (appNum.match(/^[0-9]{10}$/)) {
        // 西暦特許出願番号形式（例：2023001234）
        const prefix = law === "patent" ? "特願" : "実願";
        const year = appNum.substring(0, 4);
        const seq = appNum.substring(4);
        return `${prefix}${year}-${seq}`;
    } else {
        // その他の形式はそのまま返す
        return appNum;
    }
}

export function formatDateString(dateStr: string): string {
    if (dateStr.match(/^[0-9]{8}$/)) {
        const year = dateStr.substring(0, 4);
        const month = dateStr.substring(4, 6);
        const day = dateStr.substring(6, 8);
        return `${year}年${month}月${day}日`;
    } else {
        return dateStr;
    }
}
