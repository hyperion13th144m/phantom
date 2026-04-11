import type { estypes } from "@elastic/elasticsearch";
import type {
  ApiResponseSuccess,
  SearchAggregations,
  Hit,
  PatentDocumentSource,
} from "@/interfaces/search-results";
import { logger } from "@/lib/logger";
import {
  SEARCH_AGGREGATION_KEYS,
  type SearchAggregationKey,
} from "@/lib/search/constants";
import type { SearchQueryParams } from "@/lib/search/schema";

type Bucket = { key: string; doc_count: number };
type SearchResult = estypes.SearchResponse<PatentDocumentSource>;
type SearchHit = estypes.SearchHit<PatentDocumentSource>;

function logHighlightDebug(hit: SearchHit) {
  if (process.env.NODE_ENV === "production" || !hit.highlight) {
    return;
  }

  logger.info("Highlight found", {
    id: hit._id,
    highlightKeys: Object.keys(hit.highlight),
    highlightSample: Object.fromEntries(
      Object.entries(hit.highlight)
        .slice(0, 2)
        .map(([key, value]) => [key, value]),
    ),
  });
}

function toHit(hit: SearchHit): Hit | null {
  if (!hit._id || !hit._source) {
    return null;
  }

  logHighlightDebug(hit);

  return {
    id: hit._id,
    score: hit._score,
    source: hit._source as Partial<PatentDocumentSource>,
    highlight: hit.highlight ?? {},
  };
}

function toHits(result: SearchResult): Hit[] {
  return (result.hits.hits ?? [])
    .map(toHit)
    .filter((hit): hit is Hit => hit !== null);
}

function getTotal(result: SearchResult): number {
  return typeof result.hits.total === "number"
    ? result.hits.total
    : (result.hits.total?.value ?? 0);
}

function getStringTermsBuckets(
  aggregations: SearchResult["aggregations"],
  key: SearchAggregationKey,
): Bucket[] {
  const aggregate = aggregations?.[key] as
    | estypes.AggregationsStringTermsAggregate
    | undefined;

  return Array.isArray(aggregate?.buckets)
    ? (aggregate.buckets as Bucket[])
    : [];
}

function createEmptyAggregations(): SearchAggregations {
  return SEARCH_AGGREGATION_KEYS.reduce(
    (acc, key) => {
      acc[key] = [];
      return acc;
    },
    {} as SearchAggregations,
  );
}

function toAggregations(
  aggregations: SearchResult["aggregations"],
): SearchAggregations {
  return SEARCH_AGGREGATION_KEYS.reduce(
    (acc, key) => {
      acc[key] = getStringTermsBuckets(aggregations, key);
      return acc;
    },
    createEmptyAggregations(),
  );
}

export function toSearchApiResponse(
  result: SearchResult,
  params: SearchQueryParams,
): ApiResponseSuccess {
  return {
    page: params.page,
    size: params.size,
    total: getTotal(result),
    hits: toHits(result),
    aggregations: toAggregations(result.aggregations),
  };
}
