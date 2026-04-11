import { logger } from "@/lib/logger";
import { NextRequest, NextResponse } from "next/server";
import { z } from "zod";

export const runtime = "nodejs";
const MONA_URL = process.env.MONA_URL || "http://localhost:3000";

const PathSegmentSchema = z.string().min(1).refine(
    (value) => !value.includes("/") && !value.includes("\\") && !value.includes(".."),
    "Invalid path segment"
);

const ParamsSchema = z.object({
    docId: PathSegmentSchema,
});


export async function GET(
    _req: NextRequest,
    context: { params: Promise<{ docId: string }> }
) {
    const parsed = ParamsSchema.safeParse(await context.params);

    if (!parsed.success) {
        return NextResponse.json({ error: parsed.error.flatten() }, { status: 400 });
    }

    const { docId } = parsed.data;

    try {
        const res = await fetch(`${MONA_URL}/documents/${docId}/json/images-information`);
        if (!res.ok) {
            return new Response(JSON.stringify({ error: 'API fetch failed' }), { status: 500 });
        }
        const data = await res.json();
        const contentType = res.headers.get('Content-Type') || 'application/json';

        return new NextResponse(JSON.stringify(data), {
            status: 200,
            headers: {
                "Cache-Control": "public, max-age=0, s-maxage=60",
                "Content-Type": contentType,
            },
        });
    } catch (error: unknown) {
        if ((error as NodeJS.ErrnoException)?.code === "ENOENT") {
            return NextResponse.json(
                {
                    error: "Images information not found",
                    docId,
                },
                { status: 404 }
            );
        }

        logger.error("Failed to fetch images information", {
            docId,
            error: (error as Error)?.message ?? String(error),
        });

        return NextResponse.json(
            {
                error: "Failed to fetch images information",
                docId,
            },
            { status: 500 }
        );
    }
}
