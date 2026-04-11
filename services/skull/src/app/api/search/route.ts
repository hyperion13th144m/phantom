import { searchDocumentsWithMetadata } from "@/lib/services/searchService";
import { NextRequest, NextResponse } from "next/server";

export async function GET(req: NextRequest) {
    try {
        const { searchParams } = new URL(req.url);

        const q = searchParams.get("q") ?? "";
        const page = Math.max(Number(searchParams.get("page") ?? "1"), 1);
        const size = Math.min(
            Math.max(Number(searchParams.get("size") ?? "20"), 1),
            100,
        );

        const parseCSV = (key: string): string[] | undefined => {
            const raw = searchParams.get(key);
            if (!raw) return undefined;
            const values = raw.split(",").map((v) => v.trim()).filter(Boolean);
            return values.length > 0 ? values : undefined;
        };

        const result = await searchDocumentsWithMetadata({
            q,
            page,
            size,
            applicants: parseCSV("applicants"),
            inventors: parseCSV("inventors"),
            law: parseCSV("law"),
            documentName: parseCSV("documentName"),
            tags: parseCSV("tags"),
            assignees: parseCSV("assignees"),
        });

        return NextResponse.json(result, { status: 200 });
    } catch (error) {
        console.error("GET /api/search failed", error);
        return NextResponse.json(
            { error: "Failed to search documents" },
            { status: 500 },
        );
    }
}