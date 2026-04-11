import { sqlite, sqlitePath } from "@/lib/db/client";

export async function GET() {
    if (sqlitePath === ":memory:") {
        return Response.json(
            { error: "インメモリデータベースはダンプできません" },
            { status: 400 },
        );
    }

    try {
        const data: Buffer = sqlite.serialize();
        const filename = "skull.db";

        return new Response(data.buffer as ArrayBuffer, {
            headers: {
                "Content-Type": "application/octet-stream",
                "Content-Disposition": `attachment; filename="${filename}"`,
                "Content-Length": String(data.length),
            },
        });
    } catch (error) {
        console.error("GET /api/db/dump failed", error);
        return Response.json({ error: "ダンプに失敗しました" }, { status: 500 });
    }
}
