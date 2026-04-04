import { getMetadata, saveMetadata } from "@/lib/services/metadataService";
import { metadataUpdateSchema } from "@/lib/validators/metadata";
import { NextRequest, NextResponse } from "next/server";

type RouteContext = {
    params: Promise<{
        docId: string;
    }>;
};

export async function GET(_req: NextRequest, context: RouteContext) {
    try {
        const { docId } = await context.params;
        const metadata = await getMetadata(docId);

        if (!metadata) {
            return NextResponse.json(
                {
                    docId,
                    assignees: [],
                    tags: [],
                    extraNumbers: [],
                    memo: "",
                    checked: false,
                    createdAt: null,
                    updatedAt: null,
                },
                { status: 200 },
            );
        }

        return NextResponse.json(metadata, { status: 200 });
    } catch (error) {
        console.error("GET /api/metadata/[docId] failed", error);
        return NextResponse.json(
            { error: "Failed to load metadata" },
            { status: 500 },
        );
    }
}

export async function PUT(req: NextRequest, context: RouteContext) {
    try {
        const { docId } = await context.params;
        const json = await req.json();
        const input = metadataUpdateSchema.parse(json);

        const saved = await saveMetadata(docId, input);

        return NextResponse.json(
            {
                ok: true,
                docId: saved.docId,
                updatedAt: saved.updatedAt,
                metadata: saved,
            },
            { status: 200 },
        );
    } catch (error: unknown) {
        console.error("PUT /api/metadata/[docId] failed", error);

        if (error instanceof Error && "issues" in error) {
            return NextResponse.json(
                { error: "Invalid request body", details: error },
                { status: 400 },
            );
        }

        return NextResponse.json(
            { error: "Failed to save metadata" },
            { status: 500 },
        );
    }
}