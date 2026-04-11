import type { estypes } from "@elastic/elasticsearch";
import type { SearchAggregations } from "@/interfaces/search-results";
import type { SearchQueryParams } from "@/lib/search/schema";

export const SEARCH_FIELDS = [
  "independentClaims.ngram^10",
  "dependentClaims.ngram^8",
  "abstract.ngram^5",
  "embodiments.ngram^3",
  "opinionContentsArticle.ngram^3",
  "inventionTitle.ngram^2",
  "technicalField.ngram^2",
  "backgroundArt.ngram^2",
  "techProblem.ngram^2",
  "techSolution.ngram^2",
  "advantageousEffects.ngram^2",
  "industrialApplicability.ngram^2",
  "referenceToDepositedBiologicalMaterial.ngram^2",
  "lawOfIndustrialRegenerate.ngram^2",
  "draftingBody.ngram^2",
  "conclusionPartArticle.ngram^2",
  "contentsOfAmendment.ngram^2",
  "ocrText.ngram^1",
  "applicationNumber.ngram^5",
  "internationalNumber.ngram^5",
  "fileReferenceId.ngram^5",
  "extraNumbers.ngram^5",
] as const;

export const SOURCE_FIELDS = [
  "docId",
  "law",
  "applicationNumber",
  "internationalNumber",
  "documentCode",
  "documentName",
  "datetime",
  "fileReferenceId",
  "inventionTitle",
  "independentClaims",
  "dependentClaims",
  "abstract",
  "applicants",
  "inventors",
  "assignees",
  "tags",
  "specialMentionMatterArticle",
  "rejectionReasonArticle",
  "extraNumbers",
] as const;

type SearchFilterParam = keyof Pick<
  SearchQueryParams,
  | "applicant"
  | "inventor"
  | "assignee"
  | "tag"
  | "documentName"
  | "specialMentionMatterArticle"
  | "rejectionReasonArticle"
  | "priorityClaims"
>;

export type SearchAggregationKey = keyof SearchAggregations;

type SearchFilterDefinition = {
  param: SearchFilterParam;
  field: string;
  aggregationKey: SearchAggregationKey;
  aggregationSize: number;
};

export const SEARCH_FILTER_DEFINITIONS = [
  {
    param: "applicant",
    field: "applicants",
    aggregationKey: "applicants",
    aggregationSize: 20,
  },
  {
    param: "inventor",
    field: "inventors",
    aggregationKey: "inventors",
    aggregationSize: 20,
  },
  {
    param: "assignee",
    field: "assignees",
    aggregationKey: "assignees",
    aggregationSize: 20,
  },
  {
    param: "tag",
    field: "tags",
    aggregationKey: "tags",
    aggregationSize: 20,
  },
  {
    param: "documentName",
    field: "documentName",
    aggregationKey: "documentNames",
    aggregationSize: 20,
  },
  {
    param: "specialMentionMatterArticle",
    field: "specialMentionMatterArticle",
    aggregationKey: "specialMentionMatterArticle",
    aggregationSize: 20,
  },
  {
    param: "rejectionReasonArticle",
    field: "rejectionReasonArticle",
    aggregationKey: "rejectionReasonArticle",
    aggregationSize: 20,
  },
  {
    param: "priorityClaims",
    field: "priorityClaims",
    aggregationKey: "priorityClaims",
    aggregationSize: 10,
  },
] as const satisfies readonly SearchFilterDefinition[];

export const SEARCH_AGGREGATION_KEYS = SEARCH_FILTER_DEFINITIONS.map(
  ({ aggregationKey }) => aggregationKey,
) as SearchAggregationKey[];

export const SEARCH_AGGREGATIONS = Object.fromEntries(
  SEARCH_FILTER_DEFINITIONS.map(
    ({ aggregationKey, field, aggregationSize }) => [
      aggregationKey,
      {
        terms: {
          field,
          size: aggregationSize,
        },
      },
    ],
  ),
) as Record<SearchAggregationKey, { terms: { field: string; size: number } }>;

export const SEARCH_HIGHLIGHT = {
  pre_tags: ["<mark>"],
  post_tags: ["</mark>"],
  require_field_match: false,
  fragment_size: 150,
  number_of_fragments: 3,
  fields: {
    independentClaims: {
      fragment_size: 150,
      number_of_fragments: 2,
    },
    dependentClaims: {
      fragment_size: 150,
      number_of_fragments: 2,
    },
    abstract: {
      fragment_size: 150,
      number_of_fragments: 1,
    },
    opinionContentsArticle: {
      fragment_size: 150,
      number_of_fragments: 2,
    },
    draftingBody: {
      fragment_size: 150,
      number_of_fragments: 2,
    },
    ocrText: {
      fragment_size: 150,
      number_of_fragments: 2,
    },
  },
} satisfies estypes.SearchHighlight;

export const SEARCH_SORT = {
  withQuery: [{ _score: { order: "desc" as const } }],
  withoutQuery: [{ datetime: { order: "desc" as const } }],
} as const satisfies Record<string, estypes.Sort>;
