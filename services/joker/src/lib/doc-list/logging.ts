import { logger } from "@/lib/logger";
import type { DocListResponseMeta } from "@/lib/doc-list/response";
import type { DocListQueryParams } from "@/lib/doc-list/schema";

function toLogPayload(params: DocListQueryParams) {
  return {
    applicants: params.applicants,
    inventors: params.inventors,
    applicationNumber: params.applicationNumber,
    fileReferenceId: params.fileReferenceId,
    law: params.law,
  };
}

export function logDocListRequest(params: DocListQueryParams, url: string) {
  logger.info("DocList search request received", {
    ...toLogPayload(params),
    url,
  });
}

export function logDocListSuccess(
  params: DocListQueryParams,
  meta: DocListResponseMeta,
) {
  logger.info("DocList search completed successfully", {
    ...toLogPayload(params),
    ...meta,
    maxResults: 100,
  });
}

export function logDocListFailure(params: DocListQueryParams, error: unknown) {
  logger.error("Elasticsearch docList search failed", {
    ...toLogPayload(params),
    error: (error as Error)?.message ?? String(error),
    stack: (error as Error)?.stack,
  });
}
