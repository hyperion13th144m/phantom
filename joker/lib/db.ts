import Database from "better-sqlite3";

const dbPath = process.env.SQLITE_PATH ?? "metadata.sqlite3";
export const db = new Database(dbPath);

// JSON1が効く前提（多くの環境でOK）。もし無い場合は後述の代替案に切替。
db.pragma("journal_mode = WAL");

db.exec(`
CREATE TABLE IF NOT EXISTS patent_metadata (
  docId TEXT PRIMARY KEY,
  assignees_json TEXT NOT NULL DEFAULT '[]',
  tags_json TEXT NOT NULL DEFAULT '[]',
  extraNumbers_json TEXT NOT NULL DEFAULT '[]',
  updatedAt TEXT NOT NULL,
  updatedBy TEXT,
  version INTEGER NOT NULL DEFAULT 1
);
`);

export type MetadataRow = {
    docId: string;
    assignees_json: string;
    tags_json: string;
    extraNumbers_json: string;
    updatedAt: string;
    updatedBy: string | null;
    version: number;
};