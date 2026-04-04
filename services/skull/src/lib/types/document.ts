import type { MetadataSyncStatusRecord } from "./sync";

export type DocumentDetail = {
    docId: string;
    inventionTitle?: string;
    abstract?: string;
    applicants?: string[];
    assignee?: string | null;
    tags?: string[];
    independentClaims?: string;
    dependentClaims?: string;
    embodiments?: string;
};

export type DocumentWithMetadata = {
    document: DocumentDetail | null;
    metadata: {
        docId: string;
        assignees: string[];
        tags: string[];
        extraNumbers: string[];
        memo: string;
        checked: boolean;
        createdAt: string | null;
        updatedAt: string | null;
    } | null;
    syncStatus: MetadataSyncStatusRecord | null;
};