import type { estypes } from "@elastic/elasticsearch";
import { ES_INDEX } from "@/lib/es";
import {
  SEARCH_AGGREGATIONS,
  SEARCH_FIELDS,
  SEARCH_FILTER_DEFINITIONS,
  SEARCH_HIGHLIGHT,
  SEARCH_SORT,
  SOURCE_FIELDS,
} from "@/lib/search/constants";
import type { SearchQueryParams } from "@/lib/search/schema";

function buildSearchFilter(
  params: SearchQueryParams,
): estypes.QueryDslQueryContainer[] {
  return SEARCH_FILTER_DEFINITIONS.flatMap(({ param, field }) => {
    const value = params[param];
    return value ? [{ match: { [field]: value } }] : [];
  });
}

function buildSearchQuery(
  q: string | undefined,
  filter: estypes.QueryDslQueryContainer[],
): estypes.QueryDslQueryContainer {
  const trimmedQuery = q?.trim();

  if (trimmedQuery) {
    return {
      bool: {
        must: [
          {
            multi_match: {
              query: trimmedQuery,
              fields: [...SEARCH_FIELDS],
              type: "best_fields",
              operator: "and",
            },
          },
        ],
        filter,
      },
    };
  }

  return {
    bool: {
      must: [{ match_all: {} }],
      filter,
    },
  };
}

export function buildSearchRequest(
  params: SearchQueryParams,
): estypes.SearchRequest {
  const filter = buildSearchFilter(params);

  return {
    index: process.env.ES_INDEX ?? ES_INDEX,
    from: (params.page - 1) * params.size,
    size: params.size,
    track_total_hits: true,
    query: buildSearchQuery(params.q, filter),
    highlight: params.withHighlight ? SEARCH_HIGHLIGHT : undefined,
    aggs: SEARCH_AGGREGATIONS,
    sort: params.q ? SEARCH_SORT.withQuery : SEARCH_SORT.withoutQuery,
    _source: [...SOURCE_FIELDS],
  };
}
