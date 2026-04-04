export type RestoreJobStatus = "running" | "completed" | "failed" | "partial";

export type RestoreJobRecord = {
    id: number;
    jobType: string;
    targetMode: "all" | "docIds";
    requestJson: string;
    status: RestoreJobStatus;
    requestedCount: number;
    succeededCount: number;
    failedCount: number;
    totalAvailable: number | null;
    startedAt: string;
    finishedAt: string | null;
    createdAt: string;
    updatedAt: string;
};

export type RestoreJobItemRecord = {
    id: number;
    jobId: number;
    docId: string;
    ok: boolean;
    errorMessage: string;
    createdAt: string;
};