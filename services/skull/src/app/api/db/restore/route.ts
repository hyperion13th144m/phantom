import { sqlitePath } from "@/lib/db/client";
import Database from "better-sqlite3";
import fs from "node:fs";
import path from "node:path";
import { NextRequest } from "next/server";

const SQLITE_MAGIC = Buffer.from("SQLite format 3\0");

export async function POST(req: NextRequest) {
  if (sqlitePath === ":memory:") {
    return Response.json(
      { error: "インメモリデータベースはリストアできません" },
      { status: 400 },
    );
  }

  try {
    const arrayBuffer = await req.arrayBuffer();
    const buffer = Buffer.from(arrayBuffer);

    if (buffer.length < 16 || !buffer.subarray(0, 16).equals(SQLITE_MAGIC)) {
      return Response.json(
        { error: "有効なSQLiteファイルではありません" },
        { status: 400 },
      );
    }

    const restoreDir = path.dirname(path.resolve(sqlitePath));
    const tmpPath = path.join(restoreDir, `.restore-${Date.now()}.tmp`);

    try {
      fs.writeFileSync(tmpPath, buffer);

      // 開けるか検証
      const testDb = new Database(tmpPath, { readonly: true });
      testDb.close();

      // アトミックなリネームで既存DBと置換
      fs.renameSync(tmpPath, path.resolve(sqlitePath));
    } catch (err) {
      try {
        fs.unlinkSync(tmpPath);
      } catch {
        // ignore
      }
      throw err;
    }

    return Response.json({
      ok: true,
      message:
        "リストアが完了しました。変更を反映するにはサーバーを再起動してください。",
    });
  } catch (error) {
    console.error("POST /api/db/restore failed", error);
    return Response.json({ error: "リストアに失敗しました" }, { status: 500 });
  }
}
