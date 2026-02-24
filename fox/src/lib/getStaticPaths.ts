import fs from "node:fs/promises";
import path from "node:path";
import { DATA_DIR } from "~/constants";

export const getStaticPaths = async () => {
    let results: string[] = [];
    try {
        const dirents = await fs.readdir(DATA_DIR, {
            recursive: true,
            withFileTypes: true,
        });
        results = await Promise.all(
            dirents
                .filter((dirent) => dirent.isFile())
                .filter((dirent) => dirent.name === "bibliography.json")
                .map(async (dirent) => {
                    const txt = await fs.readFile(
                        path.join(dirent.parentPath, dirent.name),
                        "utf-8",
                    );
                    const json = JSON.parse(txt);
                    return json["docId"] as string;
                }),
        );
    } catch (err) {
        console.error("Error reading content directory:", err);
        results.length = 0; // Clear results on error
    }
    return results.map((docId) => ({ params: { docId } }));
};
