export type MetadataSyncState = "pending" | "success" | "failed";

export type MetadataSyncStatusRecord = {
    docId: string;
    syncStatus: MetadataSyncState;
    errorMessage: string;
    retryCount: number;
    lastAttemptedAt: string | null;
    lastSucceededAt: string | null;
    createdAt: string;
    updatedAt: string;
};