export class DocumentDate {
    date: Date;

    constructor(dateStr: string) {
        if (dateStr.match(/^[0-9]{8}$/)) {
            const year = dateStr.substring(0, 4);
            const month = dateStr.substring(4, 6);
            const day = dateStr.substring(6, 8);
            this.date = new Date(Number(year), Number(month) - 1, Number(day));
        } else {
            throw new Error("Invalid date format");
        }
    }

    toString(): string {
        const month = this.date.getMonth() + 1;
        const day = this.date.getDate();
        return `${this.date.getFullYear()}-${month.toString().padStart(2, "0")}-${day
            .toString()
            .padStart(2, "0")}`;
    }

    toJapaneseString(): string {
        const month = this.date.getMonth() + 1;
        const day = this.date.getDate();
        return `${this.date.getFullYear()}年 ${month.toString().padStart(2, "0")}月 ${day.toString().padStart(2, "0")}日`;
    }
}
