import Database from "better-sqlite3";
import { drizzle } from "drizzle-orm/better-sqlite3";

const sqlitePath = process.env.SQLITE_PATH ?? "./sqlite/skull.db";

const sqlite = new Database(sqlitePath);
export const db = drizzle(sqlite);