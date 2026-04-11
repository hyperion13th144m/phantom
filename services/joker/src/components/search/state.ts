import type { ApiResponseSuccess } from "@/interfaces/search-results";
import { clamp } from "@/lib/helpers";

export const MIN_PAGE = 1;
export const MAX_PAGE = 100000;
export const MIN_SIZE = 1;
export const MAX_SIZE = 100;

export type SearchQuery = {
  q: string;
  page: number;
  size: number;
  applicant: string;
  inventor: string;
  assignee: string;
  tag: string;
  documentName: string;
  specialMentionMatterArticle: string;
  rejectionReasonArticle: string;
  priorityClaims: string;
};

export type AggregationKey = keyof ApiResponseSuccess["aggregations"];
export type FilterParam = Exclude<keyof SearchQuery, "q" | "page" | "size">;
export type SearchFilters = Record<FilterParam, string>;

type FilterDefinition = {
  key: AggregationKey;
  label: string;
  param: FilterParam;
};

type SearchParamsLike = {
  get: (name: string) => string | null;
};

export const FILTERS: FilterDefinition[] = [
  { key: "applicants", label: "出願人", param: "applicant" },
  { key: "inventors", label: "発明者", param: "inventor" },
  { key: "assignees", label: "担当者", param: "assignee" },
  { key: "tags", label: "タグ", param: "tag" },
  { key: "documentNames", label: "文書名", param: "documentName" },
  {
    key: "specialMentionMatterArticle",
    label: "特記事項",
    param: "specialMentionMatterArticle",
  },
  {
    key: "rejectionReasonArticle",
    label: "拒絶理由",
    param: "rejectionReasonArticle",
  },
  { key: "priorityClaims", label: "優先権", param: "priorityClaims" },
];

export function parseSearchQuery(searchParams: SearchParamsLike): SearchQuery {
  return {
    q: searchParams.get("q") ?? "",
    page: clamp(
      Number(searchParams.get("page") ?? "1") || 1,
      MIN_PAGE,
      MAX_PAGE,
    ),
    size: clamp(
      Number(searchParams.get("size") ?? "10") || 10,
      MIN_SIZE,
      MAX_SIZE,
    ),
    applicant: searchParams.get("applicant") ?? "",
    inventor: searchParams.get("inventor") ?? "",
    assignee: searchParams.get("assignee") ?? "",
    tag: searchParams.get("tag") ?? "",
    documentName: searchParams.get("documentName") ?? "",
    specialMentionMatterArticle:
      searchParams.get("specialMentionMatterArticle") ?? "",
    rejectionReasonArticle: searchParams.get("rejectionReasonArticle") ?? "",
    priorityClaims: searchParams.get("priorityClaims") ?? "",
  };
}

export function getInitialFilters(query: SearchQuery): SearchFilters {
  return {
    applicant: query.applicant,
    inventor: query.inventor,
    assignee: query.assignee,
    tag: query.tag,
    documentName: query.documentName,
    specialMentionMatterArticle: query.specialMentionMatterArticle,
    rejectionReasonArticle: query.rejectionReasonArticle,
    priorityClaims: query.priorityClaims,
  };
}

export function buildSearchParams(query: SearchQuery): URLSearchParams {
  const params = new URLSearchParams();

  if (query.q.trim()) {
    params.set("q", query.q.trim());
  }

  params.set("page", String(query.page));
  params.set("size", String(query.size));
  params.set("withHighlight", "true");

  FILTERS.forEach(({ param }) => {
    const value = query[param].trim();
    if (value) {
      params.set(param, value);
    }
  });

  return params;
}
