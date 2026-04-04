import type { MetadataSyncStatusRecord } from "@/lib/types/sync";

type SyncStatusBadgeProps = {
    syncStatus: MetadataSyncStatusRecord | null | undefined;
};

function getLabel(syncStatus: MetadataSyncStatusRecord | null | undefined) {
    if (!syncStatus) {
        return {
            text: "not tracked",
            className: "bg-gray-100 text-gray-700 border-gray-200",
        };
    }

    switch (syncStatus.syncStatus) {
        case "success":
            return {
                text: "success",
                className: "bg-green-100 text-green-800 border-green-200",
            };
        case "pending":
            return {
                text: "pending",
                className: "bg-yellow-100 text-yellow-800 border-yellow-200",
            };
        case "failed":
            return {
                text: "failed",
                className: "bg-red-100 text-red-800 border-red-200",
            };
        default:
            return {
                text: syncStatus.syncStatus,
                className: "bg-gray-100 text-gray-700 border-gray-200",
            };
    }
}

export default function SyncStatusBadge({
    syncStatus,
}: SyncStatusBadgeProps) {
    const info = getLabel(syncStatus);

    return (
        <span
            className={`inline-flex rounded-full border px-2 py-1 text-xs font-medium ${info.className}`}
            title={syncStatus?.errorMessage || ""}
        >
            {info.text}
        </span>
    );
}