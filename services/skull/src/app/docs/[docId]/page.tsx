import Link from "next/link";
import DocumentSummary from "@/components/document/DocumentSummary";
import MetadataEditor from "@/components/metadata/MetadataEditor";
import type { DocumentWithMetadata } from "@/lib/types/document";

type DocPageProps = {
    params: Promise<{
        docId: string;
    }>;
};

async function fetchDocumentWithMetadata(
    docId: string,
): Promise<DocumentWithMetadata> {
    const baseUrl = process.env.NEXT_PUBLIC_APP_URL ?? "http://localhost:3000";

    const res = await fetch(
        `${baseUrl}/api/docs/${encodeURIComponent(docId)}`,
        {
            cache: "no-store",
        },
    );

    const json = await res.json();

    if (!res.ok && res.status !== 404) {
        throw new Error(json?.error ?? "Failed to fetch document");
    }

    return {
        document: json.document ?? null,
        metadata: json.metadata ?? null,
        syncStatus: json.syncStatus ?? null,
    };
}

export default async function DocPage({ params }: DocPageProps) {
    const { docId } = await params;
    const result = await fetchDocumentWithMetadata(docId);

    const initialMetadata = result.metadata
        ? {
            docId: result.metadata.docId,
            assignees: result.metadata.assignees,
            tags: result.metadata.tags,
            extraNumbers: result.metadata.extraNumbers,
            memo: result.metadata.memo,
            checked: result.metadata.checked,
            createdAt: result.metadata.createdAt,
            updatedAt: result.metadata.updatedAt,
        }
        : null;

    return (
        <main className="mx-auto max-w-5xl p-6 space-y-6">
            <div className="flex items-center justify-between">
                <div className="space-y-2">
                    <h1 className="text-2xl font-bold">文書の詳細</h1>
                    <p className="text-sm text-gray-600">docId: {docId}</p>
                </div>

                <Link
                    href={'/search'}
                    className="rounded-lg border px-4 py-2 hover:bg-gray-50"
                >
                    検索へ戻る
                </Link>
            </div>

            <DocumentSummary
                document={result.document}
                syncStatus={result.syncStatus}
            />

            <MetadataEditor docId={docId} initialMetadata={initialMetadata} />
        </main>
    );
}