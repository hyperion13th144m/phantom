// scripts/build-inventor-index.ts
import fs from "node:fs/promises";
import path from "node:path";
import type { ApplicantIndexEntry } from "~/interfaces/index/applicant-index";
import { getDocIds } from "~/lib/getDocIds";
import { readApplicantIndexSource } from "~/lib/readApplicantIndexSource";

type ApplicantIndex = Record<string, ApplicantIndexEntry>;
async function main() {
    const index: ApplicantIndex = {};
    const docIdList = await getDocIds();

    for (const p of docIdList) {
        const docId = p.params.docId;
        const applicantEntries = await readApplicantIndexSource(docId);

        if (applicantEntries === null) {
            continue;
        }

        for (const slug of Object.keys(applicantEntries)) {
            if (index[slug])
                index[slug].documents.push(...applicantEntries[slug].documents);
            else
                index[slug] = applicantEntries[slug];
        }
    }

    const outDir = path.join(process.cwd(), "public", "content", "_indexes");
    await fs.mkdir(outDir, { recursive: true });
    await fs.writeFile(
        path.join(outDir, "applicant-index.json"),
        JSON.stringify(index, null, 2),
        "utf-8"
    );
}

main().catch((e) => {
    console.error(e);
    process.exit(1);
});
