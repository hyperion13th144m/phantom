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
        return `${this.date.getFullYear()}年 ${this.date.getMonth() + 1}月 ${this.date.getDate()}日`;
    }
}
