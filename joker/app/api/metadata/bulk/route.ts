import { db } from "@/lib/db";
import { es, ES_INDEX } from "@/lib/es";
import { normalizeList, nowIso } from "@/lib/normalize";
import { NextResponse } from "next/server";
import { z } from "zod";

export const runtime = "nodejs";

const UpdateSchema = z.object({
    docId: z.string().min(1),
    assignees: z.any().optional(),
    tags: z.any().optional(),
    extraNumbers: z.any().optional(),
    updatedBy: z.string().optional(),
    expectedVersion: z.number().int().optional(),
});

const BodySchema = z.object({
    updates: z.array(UpdateSchema).min(1).max(2000),
});

export async function POST(req: Request) {
    const bodyJson = await req.json().catch(() => null);
    const parsed = BodySchema.safeParse(bodyJson);
    if (!parsed.success) {
        return NextResponse.json({ error: parsed.error.flatten() }, { status: 400 });
    }

    const updatedAt = nowIso();

    // 1) SQLite: トランザクションで upsert
    const selectStmt = db.prepare(`
        SELECT docId, assignees_json, tags_json, extraNumbers_json, version
        FROM patent_metadata WHERE docId = ?
    `);

    const upsertStmt = db.prepare(`
        INSERT INTO patent_metadata (docId, assignees_json, tags_json, extraNumbers_json, updatedAt, updatedBy, version)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(docId) DO UPDATE SET
            assignees_json=excluded.assignees_json,
            tags_json=excluded.tags_json,
            extraNumbers_json=excluded.extraNumbers_json,
            updatedAt=excluded.updatedAt,
            updatedBy=excluded.updatedBy,
            version=excluded.version
    `);

    const results: Array<{ docId: string; ok: boolean; status?: number; error?: string; version?: number }> = [];

    const payloadForEs: Array<{ docId: string; assignees: string[]; tags: string[]; extraNumbers: string[] }> = [];

    const tx = db.transaction(() => {
        for (const u of parsed.data.updates) {
            const current = selectStmt.get(u.docId) as any | undefined;

            if (u.expectedVersion !== undefined && (current?.version ?? 0) !== u.expectedVersion) {
                results.push({ docId: u.docId, ok: false, status: 409, error: "Version conflict" });
                continue;
            }

            const nextAssignees = u.assignees !== undefined
                ? normalizeList(u.assignees, { max: 20 })
                : (current ? JSON.parse(current.assignees_json) : []);

            const nextTags = u.tags !== undefined
                ? normalizeList(u.tags, { max: 50 })
                : (current ? JSON.parse(current.tags_json) : []);

            const nextExtra = u.extraNumbers !== undefined
                ? normalizeList(u.extraNumbers, { max: 20 })
                : (current ? JSON.parse(current.extraNumbers_json) : []);

            const nextVersion = (current?.version ?? 0) + 1;

            upsertStmt.run(
                u.docId,
                JSON.stringify(nextAssignees),
                JSON.stringify(nextTags),
                JSON.stringify(nextExtra),
                updatedAt,
                u.updatedBy ?? null,
                nextVersion
            );

            payloadForEs.push({ docId: u.docId, assignees: nextAssignees, tags: nextTags, extraNumbers: nextExtra });
            results.push({ docId: u.docId, ok: true, version: nextVersion });
        }
    });

    tx();

    // 2) ES: bulk update（SQLiteでOKになった分だけ送る）
    const okUpdates = payloadForEs;
    if (okUpdates.length === 0) {
        return NextResponse.json({ updatedAt, results });
    }

    const operations: any[] = [];
    for (const it of okUpdates) {
        operations.push({ update: { _index: ES_INDEX, _id: it.docId } });
        operations.push({
            doc: {
                assignees: it.assignees,
                tags: it.tags,
                extraNumbers: it.extraNumbers,
            },
        });
    }

    try {
        const bulkResp = await es.bulk({ refresh: false, operations });

        // ES側の個別エラー反映（SQLiteは正本なので、UIに通知できるようにする）
        if (bulkResp.errors) {
            // itemsは update/update/...
            bulkResp.items.forEach((item: any, idx: number) => {
                const u = item.update;
                if (u?.error) {
                    const docId = okUpdates[idx].docId;
                    const r = results.find(x => x.docId === docId);
                    if (r) {
                        r.ok = false;
                        r.status = u.status ?? 502;
                        r.error = u.error?.reason ?? "ES bulk update error";
                    }
                }
            });
        }
    } catch (e: any) {
        return NextResponse.json(
            { error: "Elasticsearch bulk failed", detail: e?.meta?.body ?? String(e), updatedAt, results },
            { status: 502 }
        );
    }

    return NextResponse.json({ updatedAt, results });
}