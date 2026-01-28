// scripts/build-index-db.ts
import sqlite from 'better-sqlite3';
import fs from "node:fs/promises";
import { INDEX_DB } from "~/constant";
import { getDocIds } from "~/lib/getDocIds";
import { parseDocumentJson } from "./parse-document-json";

const docSql = `CREATE TABLE IF NOT EXISTS documents
  (docId TEXT PRIMARY KEY,
   appNumSlug TEXT,
   appNumFormatted TEXT,
   documentName TEXT,
   docYear TEXT,
   docDate TEXT,
   docDateFormatted TEXT,
   fileReferenceId TEXT);`;
const applicantSql = `CREATE TABLE IF NOT EXISTS applicants 
  (slug TEXT,
   name TEXT,
   docId TEXT);`;

const indexSql = `
CREATE INDEX IF NOT EXISTS idx_document_docId ON documents (docId);
CREATE INDEX IF NOT EXISTS idx_applicant_docId ON applicants (docId);
`;
//CREATE INDEX IF NOT EXISTS idx_document_docId ON documents (docId);
//CREATE INDEX IF NOT EXISTS idx_document_slug  ON documents (appNumSlug);
//CREATE INDEX IF NOT EXISTS idx_document_year  ON documents (docYear);
//CREATE INDEX IF NOT EXISTS idx_document_fileReferenceId  ON documents (fileReferenceId);
//CREATE INDEX IF NOT EXISTS idx_applicant_docId ON applicants (docId);
//CREATE INDEX IF NOT EXISTS idx_applicant_slug  ON applicants (slug);


async function main() {
    // always delete existing index db to avoid stale data
    await fs.unlink(INDEX_DB).catch(() => { /* ignore error */ });

    // create new index db and tables
    const db = new sqlite(INDEX_DB);
    db.prepare(docSql).run();
    db.prepare(applicantSql).run();

    const docIdList = await getDocIds();

    for (const p of docIdList) {
        const docId = p.params.docId;
        const entries = await parseDocumentJson(docId);

        if (entries === null) {
            continue;
        }

        const insertDocs = db.prepare(
            `INSERT INTO documents 
            (docId, documentName, appNumSlug, appNumFormatted, docYear, docDate, docDateFormatted, fileReferenceId)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)`);
        insertDocs.run(
            entries.docId,
            entries.documentName,
            entries.appNum.slug,
            entries.appNum.toString(),
            entries.appNum.yearPart,
            entries.documentDate,
            entries.documentDateFormatted,
            entries.fileReferenceId,
        );

        for (const applicant of entries.applicants) {
            const insertApplicants = db.prepare(
                `INSERT INTO applicants 
                (slug, name, docId)
                VALUES (?, ?, ?)`);
            insertApplicants.run(
                applicant.slug,
                applicant.name,
                entries.docId,
            );
        }
    }

    db.exec(indexSql);
    db.close();
}

main().catch((e) => {
    console.error(e);
    process.exit(1);
});
