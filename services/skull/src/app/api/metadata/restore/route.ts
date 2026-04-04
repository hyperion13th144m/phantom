import { restoreMetadataToElasticsearch } from "@/lib/services/restoreService";
import { metadataRestoreSchema } from "@/lib/validators/metadataRestore";
import { NextRequest, NextResponse } from "next/server";

export async function POST(req: NextRequest) {
    try {
        const json = await req.json();
        const input = metadataRestoreSchema.parse(json);

        const result = await restoreMetadataToElasticsearch({
            all: input.all,
            docIds: input.docIds,
            limit: input.limit,
            offset: input.offset,
            batchSize: input.batchSize,
        });

        return NextResponse.json(
            {
                ok: result.failed === 0,
                requested: result.requested,
                succeeded: result.succeeded,
                failed: result.failed,
                totalAvailable: result.totalAvailable,
                results: result.results,
            },
            { status: 200 },
        );
    } catch (error: unknown) {
        console.error("POST /api/metadata/restore failed", error);

        if (error instanceof Error && "issues" in error) {
            return NextResponse.json(
                { error: "Invalid request body", details: error },
                { status: 400 },
            );
        }

        return NextResponse.json(
            { error: "Failed to restore metadata" },
            { status: 500 },
        );
    }
}