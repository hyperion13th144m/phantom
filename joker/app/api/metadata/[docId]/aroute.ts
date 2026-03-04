import { db } from "@/lib/db";
import { es, ES_INDEX } from "@/lib/es";
import { normalizeList, nowIso } from "@/lib/normalize";
import { NextResponse } from "next/server";
import { z } from "zod";

export const runtime = "nodejs";

const BodySchema = z.object({
    assignees: z.any().optional(),
    tags: z.any().optional(),
    extraNumbers: z.any().optional(),
    updatedBy: z.string().optional(),
    expectedVersion: z.number().int().optional(), // 楽観ロック（任意）
});

export async function PATCH(
    req: Request,
    { params }: { params: { docId: string } }
) {
    const docId = params.docId;

    const bodyJson = await req.json().catch(() => null);
    const parsed = BodySchema.safeParse(bodyJson);
    if (!parsed.success) {
        return NextResponse.json({ error: parsed.error.flatten() }, { status: 400 });
    }

    const assignees = parsed.data.assignees !== undefined ? normalizeList(parsed.data.assignees, { max: 20 }) : undefined;
    const tags = parsed.data.tags !== undefined ? normalizeList(parsed.data.tags, { max: 50 }) : undefined;
    const extraNumbers = parsed.data.extraNumbers !== undefined ? normalizeList(parsed.data.extraNumbers, { max: 20 }) : undefined;

    if (assignees === undefined && tags === undefined && extraNumbers === undefined) {
        return NextResponse.json({ error: "No fields to update" }, { status: 400 });
    }

    const updatedAt = nowIso();
    const updatedBy = parsed.data.updatedBy ?? null;

    // 現行行を取得（無ければ新規作成扱いでOKにする）
    const current = db.prepare(`
        SELECT docId, assignees_json, tags_json, extraNumbers_json, version
        FROM patent_metadata WHERE docId = ?
    `).get(docId) as any | undefined;

    if (parsed.data.expectedVersion !== undefined && (current?.version ?? 0) !== parsed.data.expectedVersion) {
        return NextResponse.json(
            { error: "Version conflict", currentVersion: current?.version ?? 0 },
            { status: 409 }
        );
    }

    const nextAssignees = assignees ?? (current ? JSON.parse(current.assignees_json) : []);
    const nextTags = tags ?? (current ? JSON.parse(current.tags_json) : []);
    const nextExtra = extraNumbers ?? (current ? JSON.parse(current.extraNumbers_json) : []);
    const nextVersion = (current?.version ?? 0) + 1;

    // SQLite upsert
    db.prepare(`
        INSERT INTO patent_metadata (docId, assignees_json, tags_json, extraNumbers_json, updatedAt, updatedBy, version)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(docId) DO UPDATE SET
            assignees_json=excluded.assignees_json,
            tags_json=excluded.tags_json,
            extraNumbers_json=excluded.extraNumbers_json,
            updatedAt=excluded.updatedAt,
            updatedBy=excluded.updatedBy,
            version=excluded.version
    `).run(
        docId,
        JSON.stringify(nextAssignees),
        JSON.stringify(nextTags),
        JSON.stringify(nextExtra),
        updatedAt,
        updatedBy,
        nextVersion
    );

    // ES partial update（docId = _id 直撃）
    try {
        await es.update({
            index: ES_INDEX,
            id: docId,
            doc: {
                assignees: nextAssignees,
                tags: nextTags,
                extraNumbers: nextExtra,
            },
        });
    } catch (e: any) {
        // ES側が存在しない(404)など：SQLiteは正本なので、エラーを返してUIに知らせる
        return NextResponse.json(
            { error: "Elasticsearch update failed", detail: e?.meta?.body ?? String(e) },
            { status: 502 }
        );
    }

    return NextResponse.json({
        docId,
        assignees: nextAssignees,
        tags: nextTags,
        extraNumbers: nextExtra,
        updatedAt,
        updatedBy,
        version: nextVersion,
    });
}