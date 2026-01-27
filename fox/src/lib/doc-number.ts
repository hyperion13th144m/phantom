// 国内出願番号形式（例：2023001234）
const domestic_number_re = /^[0-9]{10}$/;

// pct 出願番号形式（例：PCTJP2023XXXXXX)
const pct_number_re = /^[A-Za-z]{2}[0-9]{4}[0-9]{6}$/;

export class ApplicationNumber {
    law: "patent" | "utilityModel";
    number: string;

    constructor(law: "patent" | "utilityModel", number: string) {
        this.law = law;
        this.number = number;
    }

    get slug(): string {
        return `${this.law}-${this.number}`;
    }

    get yearPart(): string | null {
        if (this.number.match(domestic_number_re)) {
            return this.number.substring(0, 4);
        } else if (this.number.match(pct_number_re)) {
            return this.number.substring(2, 6);
        } else {
            return null;
        }
    }

    toString(): string {
        if (this.number.match(domestic_number_re)) {
            const prefix = this.law === "patent" ? "特願" : "実願";
            const year = this.number.substring(0, 4);
            const seq = this.number.substring(4);
            return `${prefix}${year}-${seq}`;
        } else if (this.number.match(pct_number_re)) {
            const country = this.number.substring(0, 2);
            const year = this.number.substring(2, 6);
            const seq = this.number.substring(6);
            return `PCT/${country}${year}/${seq}`;
        } else {
            // その他の形式はそのまま返す
            return this.number;
        }
    }
}
