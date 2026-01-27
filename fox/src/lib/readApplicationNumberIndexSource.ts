// src/lib/readApplicationIndexSource.ts
// document.json からApplicationNumberを抽出し、ApplicationNumber Index を作成するモジュール
import fs from "node:fs/promises";
import path from "node:path";
import type { DocumentJson } from "~/interfaces/document";
import { type ApplicationNumberIndexEntry } from "~/interfaces/index/application-number-index";
import { ApplicationNumber } from "~/lib/doc-number";
import { id2dir } from "~/lib/path";
import { DocumentDate } from "./doc-date";


export async function readApplicationNumberIndexSource(docId: string): Promise<Record<string, ApplicationNumberIndexEntry> | null> {
    const contentRoot = path.join(process.cwd(), "public", "content", id2dir(docId));
    const documentPath = path.resolve(contentRoot, "document.json");
    const raw = await fs.readFile(documentPath, "utf-8");
    const document: DocumentJson = JSON.parse(raw);

    if (!document.applicationNumber && !document.internationalApplicationNumber && !document.receiptNumber) {
        return null;
    }
    const an = document.applicationNumber ?? document.internationalApplicationNumber ?? document.receiptNumber ?? "";
    const app = new ApplicationNumber(document.law, an);
    const applicationNumberString = app.toString();
    const applicationNumberSlug = app.slug;

    const documentDate = document.submissionDate ?? document.dispatchDate ?? "";
    const documentDateFormatted = documentDate ? new DocumentDate(documentDate).toJapaneseString() : "";

    return {
        [applicationNumberSlug]: {
            yearPart: app.yearPart ?? "出願年不明",
            applicationNumberString,
            documents: [
                {
                    docId,
                    documentName: document.documentName ?? "",
                    documentDate,
                    documentDateFormatted,
                    fileReferenceId: document.fileReferenceId ?? "",
                }
            ]
        }
    };
}
