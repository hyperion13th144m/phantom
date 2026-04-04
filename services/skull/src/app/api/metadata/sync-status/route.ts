import { getUnsyncedStatusPage } from "@/lib/services/syncService";
import type { MetadataSyncState } from "@/lib/types/sync";
import { NextRequest, NextResponse } from "next/server";

function parseStatuses(raw: string | null): MetadataSyncState[] {
    if (!raw) return ["pending", "failed"];

    const values = raw
        .split(",")
        .map((v) => v.trim())
        .filter(Boolean);

    const filtered = values.filter(
        (v): v is MetadataSyncState =>
            v === "pending" || v === "failed" || v === "success",
    );

    return filtered.length > 0 ? filtered : ["pending", "failed"];
}

export async function GET(req: NextRequest) {
    try {
        const { searchParams } = new URL(req.url);

        const statuses = parseStatuses(searchParams.get("statuses"));
        const limit = Math.min(
            Math.max(Number(searchParams.get("limit") ?? "100"), 1),
            500,
        );
        const offset = Math.max(Number(searchParams.get("offset") ?? "0"), 0);

        const result = await getUnsyncedStatusPage({
            statuses,
            limit,
            offset,
        });

        return NextResponse.json(
            {
                total: result.total,
                limit,
                offset,
                items: result.items,
            },
            { status: 200 },
        );
    } catch (error) {
        console.error("GET /api/metadata/sync-status failed", error);
        return NextResponse.json(
            { error: "Failed to load sync statuses" },
            { status: 500 },
        );
    }
}