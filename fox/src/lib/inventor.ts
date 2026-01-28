import { generateId } from "~/lib/generate-id";


export class Inventor {
    name: string;

    constructor(name: string) {
        this.name = name;
    }

    get slug(): string {
        return generateId(this.name.trim(), "inv");
    }
}
