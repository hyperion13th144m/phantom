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
    imageName: PathSegmentSchema,
});


export async function GET(
    _req: NextRequest,
    context: { params: Promise<{ docId: string; imageName: string }> }
) {
    const parsed = ParamsSchema.safeParse(await context.params);

    if (!parsed.success) {
        return NextResponse.json({ error: parsed.error.flatten() }, { status: 400 });
    }

    if (process.env.NODE_ENV !== "development") {
        return NextResponse.json({ error: "This API is only available in development environment" }, { status: 403 });
    }

    const { docId, imageName } = parsed.data;

    try {
        const res = await fetch(`${MONA_URL}/documents/${docId}/images/${imageName}`);
        if (!res.ok) {
            return new Response(JSON.stringify({ error: 'API fetch failed' }), { status: 500 });
        }
        const data = await res.arrayBuffer();
        const contentType = res.headers.get('Content-Type') || 'application/octet-stream';

        return new NextResponse(data, {
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
                    error: "Image not found",
                    docId,
                    imageName,
                },
                { status: 404 }
            );
        }

        logger.error("Failed to load development image", {
            docId,
            imageName,
            error: (error as Error)?.message ?? String(error),
        });

        return NextResponse.json(
            {
                error: "Failed to load image",
                docId,
                imageName,
            },
            { status: 500 }
        );
    }
}
