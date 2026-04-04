import type { DocumentDetail } from "../types/document";
import { ES_INDEX, esClient } from "./client";

export async function getDocumentById(
    docId: string,
): Promise<DocumentDetail | null> {
    try {
        const response = await esClient.get({
            index: ES_INDEX,
            id: docId,
        });

        const source = (response._source ?? {}) as Record<string, unknown>;

        return {
            docId,
            inventionTitle:
                typeof source.inventionTitle === "string"
                    ? source.inventionTitle
                    : undefined,
            abstract:
                typeof source.abstract === "string" ? source.abstract : undefined,
            applicants: Array.isArray(source.applicants)
                ? source.applicants.filter((v): v is string => typeof v === "string")
                : undefined,
            assignee:
                typeof source.assignee === "string" ? source.assignee : null,
            tags: Array.isArray(source.tags)
                ? source.tags.filter((v): v is string => typeof v === "string")
                : undefined,
            independentClaims:
                typeof source.independentClaims === "string"
                    ? source.independentClaims
                    : undefined,
            dependentClaims:
                typeof source.dependentClaims === "string"
                    ? source.dependentClaims
                    : undefined,
            embodiments:
                typeof source.embodiments === "string"
                    ? source.embodiments
                    : undefined,
        };
    } catch (error: unknown) {
        const statusCode =
            typeof error === "object" &&
                error !== null &&
                "meta" in error &&
                typeof (error as { meta?: { statusCode?: number } }).meta?.statusCode ===
                "number"
                ? (error as { meta: { statusCode: number } }).meta.statusCode
                : undefined;

        if (statusCode === 404) {
            return null;
        }

        throw error;
    }
}