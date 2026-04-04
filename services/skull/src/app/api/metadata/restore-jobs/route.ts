import { listRestoreJobs } from "@/lib/db/restoreJobRepository";
import { NextRequest, NextResponse } from "next/server";

export async function GET(req: NextRequest) {
    try {
        const { searchParams } = new URL(req.url);
        const limit = Math.min(Math.max(Number(searchParams.get("limit") ?? "50"), 1), 200);
        const offset = Math.max(Number(searchParams.get("offset") ?? "0"), 0);

        const items = await listRestoreJobs({ limit, offset });

        return NextResponse.json({ limit, offset, items }, { status: 200 });
    } catch (error) {
        console.error("GET /api/metadata/restore-jobs failed", error);
        return NextResponse.json(
            { error: "Failed to load restore jobs" },
            { status: 500 },
        );
    }
}