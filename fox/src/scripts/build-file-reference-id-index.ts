// scripts/build-file-reference-id-index.ts
import fs from "node:fs/promises";
import path from "node:path";
import type { FileReferenceIdIndexEntry } from "~/interfaces/index/file-reference-id-index";
import { getDocIds } from "~/lib/getDocIds";
import { readFileReferenceIdIndexSource } from "~/lib/readFileReferenceIdIndexSource";

type FileReferenceIdIndex = Record<string, FileReferenceIdIndexEntry>;
async function main() {
    const index: FileReferenceIdIndex = {};
    const docIdList = await getDocIds();

    for (const p of docIdList) {
        const docId = p.params.docId;
        const fileReferenceIdEntries = await readFileReferenceIdIndexSource(docId);

        if (fileReferenceIdEntries === null) {
            continue;
        }

        for (const slug of Object.keys(fileReferenceIdEntries)) {
            if (index[slug])
                index[slug].documents.push(...fileReferenceIdEntries[slug].documents);
            else
                index[slug] = fileReferenceIdEntries[slug];
        }
    }

    const outDir = path.join(process.cwd(), "public", "content", "_indexes");
    await fs.mkdir(outDir, { recursive: true });
    await fs.writeFile(
        path.join(outDir, "file-reference-id-index.json"),
        JSON.stringify(index, null, 2),
        "utf-8"
    );
}

main().catch((e) => {
    console.error(e);
    process.exit(1);
});
