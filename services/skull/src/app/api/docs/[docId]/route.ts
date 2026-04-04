import { getDocumentWithMetadata } from "@/lib/services/documentService";
import { NextRequest, NextResponse } from "next/server";

type RouteContext = {
    params: Promise<{
        docId: string;
    }>;
};

export async function GET(_req: NextRequest, context: RouteContext) {
    try {
        const { docId } = await context.params;
        const result = await getDocumentWithMetadata(docId);

        if (!result.document) {
            return NextResponse.json(
                {
                    error: "Document not found",
                    document: null,
                    metadata: result.metadata,
                    syncStatus: result.syncStatus,
                },
                { status: 404 },
            );
        }

        return NextResponse.json(result, { status: 200 });
    } catch (error) {
        console.error("GET /api/docs/[docId] failed", error);
        return NextResponse.json(
            { error: "Failed to load document" },
            { status: 500 },
        );
    }
}