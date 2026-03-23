import { db } from "@/lib/db";
import { NextResponse } from "next/server";
import { z } from "zod";

export const runtime = "nodejs";

const BodySchema = z.object({
    docIds: z.array(z.string().min(1)).min(1).max(2000),
});

export async function POST(req: Request) {
    const bodyJson = await req.json().catch(() => null);
    const parsed = BodySchema.safeParse(bodyJson);
    if (!parsed.success) {
        return NextResponse.json({ error: parsed.error.flatten() }, { status: 400 });
    }

    const docIds = parsed.data.docIds;

    // IN句を安全に生成（better-sqlite3）
    const placeholders = docIds.map(() => "?").join(",");
    const stmt = db.prepare(`
    SELECT docId, assignees_json, tags_json, extraNumbers_json, updatedAt, updatedBy, version
    FROM patent_metadata
    WHERE docId IN (${placeholders})
  `);

    const rows = stmt.all(...docIds) as any[];

    // map化して返す（無いdocIdは返さない＝UI側でデフォルト空にする）
    const byId: Record<string, any> = {};
    for (const r of rows) {
        byId[r.docId] = {
            docId: r.docId,
            assignees: JSON.parse(r.assignees_json) as string[],
            tags: JSON.parse(r.tags_json) as string[],
            extraNumbers: JSON.parse(r.extraNumbers_json) as string[],
            updatedAt: r.updatedAt,
            updatedBy: r.updatedBy,
            version: r.version,
        };
    }

    return NextResponse.json({ byId });
}