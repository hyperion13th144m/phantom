// scripts/build-inventor-index.ts
import fs from "node:fs/promises";
import path from "node:path";
import type { InventorIndexEntry } from "~/interfaces/index/inventor-index";
import { getDocIds } from "~/lib/getDocIds";
import { readInventorIndexSource } from "~/lib/readInventorIndexSource";

type InventorIndex = Record<string, InventorIndexEntry>;

async function main() {
    const index: InventorIndex = {};
    const docIdList = await getDocIds();

    for (const p of docIdList) {
        const docId = p.params.docId;
        const inventorEntries = await readInventorIndexSource(docId);

        if (inventorEntries === null) {
            continue;
        }

        for (const slug of Object.keys(inventorEntries)) {
            if (index[slug])
                index[slug].documents.push(...inventorEntries[slug].documents);
            else
                index[slug] = inventorEntries[slug];
        }
    }

    const outDir = path.join(process.cwd(), "public", "content", "_indexes");
    await fs.mkdir(outDir, { recursive: true });
    await fs.writeFile(
        path.join(outDir, "inventor-index.json"),
        JSON.stringify(index, null, 2),
        "utf-8"
    );
}

main().catch((e) => {
    console.error(e);
    process.exit(1);
});
