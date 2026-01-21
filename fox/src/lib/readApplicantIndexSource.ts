// src/lib/readInventorIndexSource.ts
// document.json から発明者名を抽出し、Inventor Index を作成するモジュール
import fs from "node:fs/promises";
import path from "node:path";
import type { DocumentJson } from "~/interfaces/document";
import { type ApplicantIndexEntry } from "~/interfaces/index/applicant-index";
import type { Block } from "~/interfaces/text-blocks-root";
import { ApplicationNumber } from "~/lib/doc-number";
import { id2dir } from "~/lib/docId";
import { generateId } from "./generate-id";


export async function readApplicantIndexSource(docId: string): Promise<Record<string, ApplicantIndexEntry>> {
    const contentRoot = path.join(process.cwd(), "public", "content", id2dir(docId));
    const documentPath = path.resolve(contentRoot, "document.json");
    const raw = await fs.readFile(documentPath, "utf-8");
    const document: DocumentJson = JSON.parse(raw);

    // inventorsだけ抽出（重い searchNested は使わない）
    const applicantNames = extractNamesFromTextBlocks(document.textBlocksRoot, "jp:applicant", "jp:name");
    const applicantIdNumbers = extractNamesFromTextBlocks(document.textBlocksRoot, "jp:applicant", "jp:registered-number");
    const applicantAddrs = extractNamesFromTextBlocks(document.textBlocksRoot, "jp:applicant", "jp:text");
    const applicantSlugs = applicantNames.map((name, index) => {
        const addrOrId = applicantIdNumbers[index] || applicantAddrs[index] || "";
        return generateId(`${name} ${addrOrId}`.trim());
    });

    const app = new ApplicationNumber(document.law, document.applicationNumber || "");
    const applicationNumberString = app.toString();
    const applicationNumberSlug = app.slug;

    const fileReferenceId = (document as any).fileReferenceId ?? null;

    return Object.fromEntries(applicantSlugs.map((app, index) => (
        [app, {
            name: applicantNames[index],
            address: applicantAddrs[index] || undefined,
            idNumber: applicantIdNumbers[index] || undefined,
            documents: [
                {
                    docId,
                    applicationNumberString,
                    applicationNumberSlug,
                    fileReferenceId,
                }
            ]
        }]
    )));
}

/** Blockツリー専用の軽量トラバース：applicantブロック直下だけ見る */
function extractNamesFromTextBlocks(root: Block[], personTag: string, nameTag: string): string[] {
    const names: string[] = [];
    const stack: any[] = Array.isArray(root) ? [...root] : [];

    while (stack.length) {
        const b = stack.pop();
        if (!b || typeof b !== "object") continue;

        if (b.tag === personTag && Array.isArray(b.blocks)) {
            for (const child of b.blocks) {
                if (child?.tag === nameTag && typeof child.text === "string") {
                    names.push(child.text);
                }
            }
            continue;
        }

        if (Array.isArray(b.blocks)) stack.push(...b.blocks);
    }
    return names;
}
