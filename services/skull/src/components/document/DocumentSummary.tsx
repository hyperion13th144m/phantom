import type { DocumentDetail } from "@/lib/types/document";
import type { MetadataSyncStatusRecord } from "@/lib/types/sync";
import SyncStatusBadge from "@/components/sync/SyncStatusBadge";
import ResyncButton from "@/components/sync/ResyncButton";

type DocumentSummaryProps = {
    document: DocumentDetail | null;
    syncStatus: MetadataSyncStatusRecord | null;
};

function Section(props: {
    title: string;
    value?: string | string[] | null;
    multiline?: boolean;
}) {
    const { title, value, multiline } = props;

    return (
        <section className="space-y-2">
            <h3 className="text-sm font-semibold text-gray-700">{title}</h3>
            <div
                className={
                    multiline
                        ? "rounded-lg bg-gray-50 p-3 text-sm whitespace-pre-wrap break-words"
                        : "rounded-lg bg-gray-50 p-3 text-sm break-words"
                }
            >
                {Array.isArray(value) ? value.join(", ") : value && value.trim() ? value : "—"}
            </div>
        </section>
    );
}

export default function DocumentSummary({
    document,
    syncStatus,
}: DocumentSummaryProps) {
    if (!document) {
        return (
            <div className="rounded-xl border bg-white p-6 shadow-sm space-y-4">
                <p className="text-sm text-red-700">
                    Elasticsearch に文書が見つかりませんでした。
                </p>

                <div className="flex items-center gap-3">
                    <span className="text-sm font-medium">sync status:</span>
                    <SyncStatusBadge syncStatus={syncStatus} />
                </div>

                {syncStatus?.errorMessage ? (
                    <div className="rounded-lg bg-red-50 p-3 text-sm text-red-800 whitespace-pre-wrap break-words">
                        {syncStatus.errorMessage}
                    </div>
                ) : null}
            </div>
        );
    }

    return (
        <div className="space-y-6 rounded-xl border bg-white p-6 shadow-sm">
            <div className="flex flex-col gap-3 md:flex-row md:items-start md:justify-between">
                <div className="space-y-2">
                    <h2 className="text-xl font-semibold">文書概要</h2>
                    <p className="text-sm text-blue-600">
                        <a href={`${process.env.NEXT_PUBLIC_DOCUMENT_BASE_URL}/${document.docId}`}>詳細表示</a>
                    </p>
                </div>

                <div className="space-y-3">
                    <div className="flex items-center gap-3">
                        <span className="text-sm font-medium">sync status:</span>
                        <SyncStatusBadge syncStatus={syncStatus} />
                    </div>

                    <ResyncButton docId={document.docId} />
                </div>
            </div>

            {syncStatus?.errorMessage ? (
                <div className="rounded-lg bg-red-50 p-3 text-sm text-red-800 whitespace-pre-wrap break-words">
                    {syncStatus.errorMessage}
                </div>
            ) : null}

            <div className="grid gap-4 md:grid-cols-2">
                <Section title="発明の名称" value={document.inventionTitle} />
                <Section
                    title="出願人"
                    value={document.applicants?.join(", ") ?? ""}
                />
                <Section title="担当者" value={document.assignee ?? ""} />
                <Section title="タグ" value={document.tags?.join(", ") ?? ""} />
            </div>

            <Section title="要約" value={document.abstract} multiline />
            <Section title="独立請求項" value={document.independentClaims} multiline />
            <Section title="従属請求項" value={document.dependentClaims} multiline />
            <Section title="補正内容" value={document.contentsOfAmendment} multiline />
            <Section title="拒絶理由結論" value={document.conclusionPartArticle} multiline />
            <Section title="拒絶理由" value={document.draftingBody} multiline />
            <Section title="意見内容" value={document.opinionContentsArticle} multiline />
        </div>
    );
}