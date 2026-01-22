// scripts/build-application-number-index.ts
import fs from "node:fs/promises";
import path from "node:path";
import type { ApplicationNumberIndexEntry } from "~/interfaces/index/application-number-index";
import { getDocIds } from "~/lib/getDocIds";
import { readApplicationNumberIndexSource } from "~/lib/readApplicationNumberIndexSource";

type ApplicationNumberIndex = Record<string, ApplicationNumberIndexEntry>;
async function main() {
    const index: ApplicationNumberIndex = {};
    const docIdList = await getDocIds();

    for (const p of docIdList) {
        const docId = p.params.docId;
        const applicationNumberEntries = await readApplicationNumberIndexSource(docId);

        if (applicationNumberEntries === null) {
            continue;
        }

        for (const slug of Object.keys(applicationNumberEntries)) {
            if (index[slug])
                index[slug].documents.push(...applicationNumberEntries[slug].documents);
            else
                index[slug] = applicationNumberEntries[slug];
        }
    }

    const outDir = path.join(process.cwd(), "public", "content", "_indexes");
    await fs.mkdir(outDir, { recursive: true });
    await fs.writeFile(
        path.join(outDir, "application-number-index.json"),
        JSON.stringify(index, null, 2),
        "utf-8"
    );
}

main().catch((e) => {
    console.error(e);
    process.exit(1);
});
