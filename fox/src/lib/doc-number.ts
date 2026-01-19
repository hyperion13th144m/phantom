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
        if (this.number.match(/^[0-9]{10}$/)) {
            return this.number.substring(0, 4);
        }
        return null;
    }

    toString(): string {
        if (this.number.match(/^[0-9]{10}$/)) {
            // 西暦特許出願番号形式（例：2023001234）
            const prefix = this.law === "patent" ? "特願" : "実願";
            const year = this.number.substring(0, 4);
            const seq = this.number.substring(4);
            return `${prefix}${year}-${seq}`;
        } else {
            // その他の形式はそのまま返す
            return this.number;
        }
    }
}
