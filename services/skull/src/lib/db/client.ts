import Database from "better-sqlite3";
import { drizzle } from "drizzle-orm/better-sqlite3";
import fs from "node:fs";
import path from "node:path";

const sqlitePath = process.env.SQLITE_PATH?.trim() || "./sqlite/skull.db";

if (sqlitePath !== ":memory:" && !sqlitePath.startsWith("file:")) {
    const sqliteDir = path.dirname(sqlitePath);
    if (sqliteDir && sqliteDir !== ".") {
        fs.mkdirSync(sqliteDir, { recursive: true });
    }
}

const sqlite = new Database(sqlitePath);
export const db = drizzle(sqlite);