import fs from "node:fs/promises";
import path from "node:path";
import { getContentRoot } from "~/constant";
import type { DocumentJson, IPDocument } from "~/interfaces/document";
import { DocumentDate } from "~/lib/doc-date";
import { ApplicationNumber } from "~/lib/doc-number";

export const getIPDocument = async (docId: string) => {
    // document.json が保存されたディレクトリのパスを取得
    const contentRoot = getContentRoot(docId);

    // document.json を読み込む
    const documentPath = path.resolve(contentRoot, "document.json");
    const documentRaw = await fs.readFile(documentPath, "utf-8");
    const document: DocumentJson = JSON.parse(documentRaw);

    // IPDocument 用のフィールドを取得・変換
    const applicants = document.applicants;
    const inventors = document.inventors;
    const agents = document.agents;
    const submissionDate = document.submissionDate ? new DocumentDate(document.submissionDate) : null;
    const dispatchDate = document.dispatchDate ? new DocumentDate(document.dispatchDate) : null;
    const an = document.applicationNumber ?? document.internationalApplicationNumber ?? document.receiptNumber ?? "";
    const applicationNumber = new ApplicationNumber(
        document.law,
        an
    );

    return {
        ...document,
        applicants,
        inventors,
        agents,
        submissionDate,
        dispatchDate,
        applicationNumber,
    } as IPDocument
}
