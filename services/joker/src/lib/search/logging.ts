import type { ApiResponseSuccess } from "@/interfaces/search-results";
import { logger } from "@/lib/logger";
import type { SearchQueryParams } from "@/lib/search/schema";

export function logSearchRequest(params: SearchQueryParams, url: string) {
  logger.info("Search request received", {
    query: params.q,
    page: params.page,
    size: params.size,
    url,
  });
}

export function logSearchSuccess(
  params: SearchQueryParams,
  response: ApiResponseSuccess,
) {
  logger.info("Search completed successfully", {
    query: params.q,
    total: response.total,
    resultsCount: response.hits.length,
    page: params.page,
  });
}

export function logSearchFailure(params: SearchQueryParams, error: unknown) {
  logger.error("Elasticsearch search failed", {
    query: params.q,
    error: (error as Error)?.message ?? String(error),
    stack: (error as Error)?.stack,
  });
}
