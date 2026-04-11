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
                Array.isArray(source.independentClaims)
                    ? source.independentClaims.filter((v): v is string => typeof v === "string")
                    : undefined,
            dependentClaims:
                Array.isArray(source.dependentClaims)
                    ? source.dependentClaims.filter((v): v is string => typeof v === "string")
                    : undefined,
            contentsOfAmendment:
                typeof source.contentsOfAmendment === "string"
                    ? source.contentsOfAmendment
                    : undefined,
            conclusionPartArticle:
                typeof source.conclusionPartArticle === "string"
                    ? source.conclusionPartArticle
                    : undefined,
            draftingBody:
                typeof source.draftingBody === "string"
                    ? source.draftingBody
                    : undefined,
            opinionContentsArticle:
                typeof source.opinionContentsArticle === "string"
                    ? source.opinionContentsArticle
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