import {
    getRestoreJobById,
    listRestoreJobItems,
} from "@/lib/db/restoreJobRepository";
import { NextRequest, NextResponse } from "next/server";

type RouteContext = {
    params: Promise<{ jobId: string }>;
};

export async function GET(req: NextRequest, context: RouteContext) {
    try {
        const { jobId } = await context.params;
        const id = Number(jobId);

        if (!Number.isInteger(id) || id <= 0) {
            return NextResponse.json({ error: "Invalid jobId" }, { status: 400 });
        }

        const { searchParams } = new URL(req.url);
        const limit = Math.min(Math.max(Number(searchParams.get("limit") ?? "200"), 1), 1000);
        const offset = Math.max(Number(searchParams.get("offset") ?? "0"), 0);

        const job = await getRestoreJobById(id);
        if (!job) {
            return NextResponse.json({ error: "Job not found" }, { status: 404 });
        }

        const items = await listRestoreJobItems(id, { limit, offset });

        return NextResponse.json(
            { job, limit, offset, items },
            { status: 200 },
        );
    } catch (error) {
        console.error("GET /api/metadata/restore-jobs/[jobId] failed", error);
        return NextResponse.json(
            { error: "Failed to load restore job detail" },
            { status: 500 },
        );
    }
}