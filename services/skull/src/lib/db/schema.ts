import { integer, sqliteTable, text } from "drizzle-orm/sqlite-core";

export const documentMetadata = sqliteTable("document_metadata", {
    docId: text("doc_id").primaryKey(),
    assigneesJson: text("assignees_json").notNull().default("[]"),
    tagsJson: text("tags_json").notNull().default("[]"),
    extraNumbersJson: text("extra_numbers_json").notNull().default("[]"),
    memo: text("memo").notNull().default(""),
    checked: integer("checked", { mode: "boolean" }).notNull().default(false),
    createdAt: text("created_at").notNull(),
    updatedAt: text("updated_at").notNull(),
});

export const metadataHistory = sqliteTable("metadata_history", {
    id: integer("id").primaryKey({ autoIncrement: true }),
    docId: text("doc_id").notNull(),
    operation: text("operation").notNull(),
    beforeJson: text("before_json").notNull(),
    afterJson: text("after_json").notNull(),
    createdAt: text("created_at").notNull(),
});

export const metadataSyncStatus = sqliteTable("metadata_sync_status", {
    docId: text("doc_id").primaryKey(),
    syncStatus: text("sync_status").notNull(), // pending | success | failed
    errorMessage: text("error_message").notNull().default(""),
    retryCount: integer("retry_count").notNull().default(0),
    lastAttemptedAt: text("last_attempted_at"),
    lastSucceededAt: text("last_succeeded_at"),
    createdAt: text("created_at").notNull(),
    updatedAt: text("updated_at").notNull(),
});

export const metadataRestoreJobs = sqliteTable("metadata_restore_jobs", {
    id: integer("id").primaryKey({ autoIncrement: true }),
    jobType: text("job_type").notNull(),
    targetMode: text("target_mode").notNull(),
    requestJson: text("request_json").notNull(),
    status: text("status").notNull(),
    requestedCount: integer("requested_count").notNull().default(0),
    succeededCount: integer("succeeded_count").notNull().default(0),
    failedCount: integer("failed_count").notNull().default(0),
    totalAvailable: integer("total_available"),
    startedAt: text("started_at").notNull(),
    finishedAt: text("finished_at"),
    createdAt: text("created_at").notNull(),
    updatedAt: text("updated_at").notNull(),
});

export const metadataRestoreJobItems = sqliteTable("metadata_restore_job_items", {
    id: integer("id").primaryKey({ autoIncrement: true }),
    jobId: integer("job_id").notNull(),
    docId: text("doc_id").notNull(),
    ok: integer("ok", { mode: "boolean" }).notNull().default(false),
    errorMessage: text("error_message").notNull().default(""),
    createdAt: text("created_at").notNull(),
});