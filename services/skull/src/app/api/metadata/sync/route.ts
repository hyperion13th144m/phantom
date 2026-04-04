import { resyncMetadataToElasticsearch } from "@/lib/services/syncService";
import { metadataSyncSchema } from "@/lib/validators/metadataSync";
import { NextRequest, NextResponse } from "next/server";

export async function POST(req: NextRequest) {
    try {
        const json = await req.json();
        const input = metadataSyncSchema.parse(json);

        const result = await resyncMetadataToElasticsearch({
            docIds: input.docIds,
            allFailed: input.allFailed,
            allPending: input.allPending,
            limit: input.limit,
            batchSize: input.batchSize,
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
        console.error("POST /api/metadata/sync failed", error);

        if (error instanceof Error && "issues" in error) {
            return NextResponse.json(
                { error: "Invalid request body", details: error },
                { status: 400 },
            );
        }

        return NextResponse.json(
            { error: "Failed to resync metadata" },
            { status: 500 },
        );
    }
}