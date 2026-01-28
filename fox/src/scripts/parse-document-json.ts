import fs from "node:fs/promises";
import path from "node:path";
import { getContentRoot } from "~/constant";
import type { DocumentJson } from "~/interfaces/document";
import { Applicant } from "~/lib/applicant";
import { DocumentDate } from "~/lib/doc-date";
import { ApplicationNumber } from "~/lib/doc-number";

const loadDocumentJson = async (docId: string): Promise<DocumentJson> => {
    const contentRoot = getContentRoot(docId);
    const documentPath = path.resolve(contentRoot, "document.json");
    const raw = await fs.readFile(documentPath, "utf-8");
    return JSON.parse(raw) as DocumentJson;
};

export async function parseDocumentJson(docId: string) {
    // docId から document.json を読み、sqlite に登録するためのデータを生成する

    const document = await loadDocumentJson(docId);
    const applicants = document.applicants.map(name => new Applicant(name)) || [];
    const appNum = new ApplicationNumber(document.law,
        document.applicationNumber ??
        document.internationalApplicationNumber ??
        document.receiptNumber ?? "");
    const fileReferenceId = (document as any).fileReferenceId ?? null;
    const documentDate = document.submissionDate ?? document.dispatchDate ?? "";
    const documentDateFormatted = documentDate ? new DocumentDate(documentDate).toJapaneseString() : "";


    if (applicants.length === 0 || document.applicationNumber === null) {
        return null;
    }

    return {
        docId,
        documentDate,
        documentDateFormatted,
        documentName: document.documentName ?? "",
        appNum,
        fileReferenceId,
        applicants,
    }
}
