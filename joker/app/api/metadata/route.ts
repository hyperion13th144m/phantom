import { db, type MetadataRow } from "@/lib/db";
import { NextResponse } from "next/server";
import { z } from "zod";

// App Router: Node runtime必須（better-sqlite3がEdge不可）
export const runtime = "nodejs";

const QuerySchema = z.object({
    page: z.coerce.number().int().min(1).default(1),
    size: z.coerce.number().int().min(1).max(200).default(50),
    q: z.string().optional(),          // docId 検索（部分一致）
    tag: z.string().optional(),        // tagsに完全一致
    assignee: z.string().optional(),   // assigneesに完全一致
    extra: z.string().optional(),      // extraNumbersに完全一致
});

function buildWhere(params: z.infer<typeof QuerySchema>) {
    const where: string[] = [];
    const binds: any[] = [];

    if (params.q && params.q.trim()) {
        where.push(`docId LIKE ?`);
        binds.push(`%${params.q.trim()}%`);
    }
    if (params.tag && params.tag.trim()) {
        where.push(`EXISTS (SELECT 1 FROM json_each(tags_json) WHERE value = ?)`);
        binds.push(params.tag.trim());
    }
    if (params.assignee && params.assignee.trim()) {
        where.push(`EXISTS (SELECT 1 FROM json_each(assignees_json) WHERE value = ?)`);
        binds.push(params.assignee.trim());
    }
    if (params.extra && params.extra.trim()) {
        where.push(`EXISTS (SELECT 1 FROM json_each(extraNumbers_json) WHERE value = ?)`);
        binds.push(params.extra.trim());
    }

    const whereSql = where.length ? `WHERE ${where.join(" AND ")}` : "";
    return { whereSql, binds };
}

export async function GET(req: Request) {
    const url = new URL(req.url);
    const parsed = QuerySchema.safeParse({
        page: url.searchParams.get("page") ?? undefined,
        size: url.searchParams.get("size") ?? undefined,
        q: url.searchParams.get("q") ?? undefined,
        tag: url.searchParams.get("tag") ?? undefined,
        assignee: url.searchParams.get("assignee") ?? undefined,
        extra: url.searchParams.get("extra") ?? undefined,
    });

    if (!parsed.success) {
        return NextResponse.json({ error: parsed.error.flatten() }, { status: 400 });
    }

    const { page, size } = parsed.data;
    const offset = (page - 1) * size;
    const { whereSql, binds } = buildWhere(parsed.data);

    const totalStmt = db.prepare<any[], { total: number }>(`
        SELECT COUNT(*) as total
        FROM patent_metadata
        ${whereSql}
    `);
    const total = totalStmt.get(...binds)?.total ?? 0;

    const rowsStmt = db.prepare<any[], MetadataRow>(`
        SELECT docId, assignees_json, tags_json, extraNumbers_json, updatedAt, updatedBy, version
        FROM patent_metadata
        ${whereSql}
        ORDER BY updatedAt DESC
        LIMIT ? OFFSET ?
    `);

    const rows = rowsStmt.all(...binds, size, offset).map((r) => ({
        docId: r.docId,
        assignees: JSON.parse(r.assignees_json) as string[],
        tags: JSON.parse(r.tags_json) as string[],
        extraNumbers: JSON.parse(r.extraNumbers_json) as string[],
        updatedAt: r.updatedAt,
        updatedBy: r.updatedBy,
        version: r.version,
    }));

    return NextResponse.json({ page, size, total, rows });
}