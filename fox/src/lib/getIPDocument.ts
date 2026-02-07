import fs from "node:fs/promises";
import path from "node:path";
import { getContentRoot } from "~/constant";
import type { IPatentDocument } from "~/interfaces/document";
import type { PatentDocument } from "~/interfaces/patent-document-schema";
import { DocumentDate } from "~/lib/doc-date";
import { ApplicationNumber } from "~/lib/doc-number";

export const getIPDocument = async (docId: string) => {
    // document.json が保存されたディレクトリのパスを取得
    const contentRoot = getContentRoot(docId);

    // document.json を読み込む
    const documentPath = path.resolve(contentRoot, "document.json");
    const documentRaw = await fs.readFile(documentPath, "utf-8");
    const document: PatentDocument = JSON.parse(documentRaw);

    // fields を一度取り出す
    const { applicants, inventors, agents } = document.fields;

    // convert date
    const submissionDate = document.submissionDate ? new DocumentDate(document.submissionDate) : null;
    const dispatchDate = document.dispatchDate ? new DocumentDate(document.dispatchDate) : null;

    const applicationNumber = createApplicationNumber(document);

    return {
        ...document,
        applicants,
        inventors,
        agents,
        submissionDate,
        dispatchDate,
        applicationNumber,
    } as IPatentDocument
}

function createApplicationNumber(doc: PatentDocument): ApplicationNumber {
    const an =
        doc.applicationNumber ??
        doc.internationalApplicationNumber ??
        doc.receiptNumber ??
        "";

    return new ApplicationNumber(doc.law, an);
}
