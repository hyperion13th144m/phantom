import { bulkUpdateMetadata } from "@//lib/services/metadataBulkService";
import { metadataBulkUpdateSchema } from "@//lib/validators/metadataBulk";
import { NextRequest, NextResponse } from "next/server";

export async function POST(req: NextRequest) {
    try {
        const json = await req.json();
        const input = metadataBulkUpdateSchema.parse(json);

        const result = await bulkUpdateMetadata({
            docIds: input.docIds,
            patch: input.patch,
        });

        return NextResponse.json(
            {
                ok: result.failed === 0,
                requested: result.requested,
                succeeded: result.succeeded,
                failed: result.failed,
                results: result.results,
            },
            { status: 200 },
        );
    } catch (error: unknown) {
        console.error("POST /api/metadata/bulk failed", error);

        if (error instanceof Error && "issues" in error) {
            return NextResponse.json(
                { error: "Invalid request body", details: error },
                { status: 400 },
            );
        }

        return NextResponse.json(
            { error: "Failed to bulk update metadata" },
            { status: 500 },
        );
    }
}