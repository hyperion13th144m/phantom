import fs from "node:fs/promises";
import path from "node:path";

export async function getDocIds() {
    // document.json を探し、docIdを返す。

    let results: string[] = [];
    const contentDir = path.join(process.cwd(), "public", "content");
    try {
        const dirents = await fs.readdir(contentDir, {
            recursive: true,
            withFileTypes: true,
        });
        results = await Promise.all(dirents
            .filter((dirent) => dirent.isFile())
            .filter((dirent) => dirent.name === "document.json")
            .map(async (dirent) => {
                const txt = await fs.readFile(path.join(dirent.parentPath, dirent.name), "utf-8");
                const json = JSON.parse(txt);
                return json['docId'] as string;
            }));
    } catch (err) {
        console.error("Error reading content directory:", err);
    }

    return results.map((docId) => ({ params: { docId } }));
}
