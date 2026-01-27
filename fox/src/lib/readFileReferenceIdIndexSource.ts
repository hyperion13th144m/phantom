// src/lib/readFileReferenceIdIndexSource.ts
// document.json からfileReferenceIdを抽出し、FileReferenceId Index を作成するモジュール
import fs from "node:fs/promises";
import path from "node:path";
import type { DocumentJson } from "~/interfaces/document";
import { type FileReferenceIdIndexEntry } from "~/interfaces/index/file-reference-id-index";
import { ApplicationNumber } from "~/lib/doc-number";
import { id2dir } from "~/lib/path";


export async function readFileReferenceIdIndexSource(docId: string): Promise<Record<string, FileReferenceIdIndexEntry> | null> {
    const contentRoot = path.join(process.cwd(), "public", "content", id2dir(docId));
    const documentPath = path.resolve(contentRoot, "document.json");
    const raw = await fs.readFile(documentPath, "utf-8");
    const document: DocumentJson = JSON.parse(raw);

    // fileReferenceIdがない場合はnullそのまま返す
    if (!document.fileReferenceId) {
        return null;
    }
    const fileReferenceId = document.fileReferenceId;
    const an = document.applicationNumber ?? document.internationalApplicationNumber ?? document.receiptNumber ?? "";
    const app = new ApplicationNumber(document.law, an);
    const applicationNumberString = app.toString();
    const applicationNumberSlug = app.slug;

    return {
        [fileReferenceId]: {
            applicationNumberSlug,
            applicationNumberString,
            documents: [
                {
                    docId,
                }
            ]
        }
    };
}
