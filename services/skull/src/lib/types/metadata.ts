import type { MetadataSyncStatusRecord } from "./sync";

export type MetadataRecord = {
    docId: string;
    assignees: string[];
    tags: string[];
    extraNumbers: string[];
    memo: string;
    checked: boolean;
    createdAt: string | null;
    updatedAt: string | null;
};

export type MetadataUpdateInput = {
    assignees?: string[];
    tags?: string[];
    extraNumbers?: string[];
    memo?: string;
    checked?: boolean;
};

export type MetadataHistoryRecord = {
    id: number;
    docId: string;
    operation: "create" | "update" | "bulk_update" | "sync";
    beforeJson: string;
    afterJson: string;
    createdAt: string;
};

export type SearchResultItem = {
    docId: string;
    inventionTitle?: string;
    applicants?: string[];
    assignee?: string | null;
    tags?: string[];
    abstract?: string;
    metadata?: MetadataRecord | null;
    syncStatus?: MetadataSyncStatusRecord | null;
};

export type SearchResponse = {
    page: number;
    size: number;
    total: number;
    items: SearchResultItem[];
};