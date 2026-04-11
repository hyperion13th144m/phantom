import type { estypes } from "@elastic/elasticsearch";

export const DOC_LIST_MAX_RESULTS = 100;

export const DOC_LIST_SOURCE_FIELDS = [
  "docId",
  "law",
  "applicationNumber",
  "applicants",
  "fileReferenceId",
  "date",
  "documentName",
  "documentCode",
  "extraNumbers",
] as const;

export const DOC_LIST_SORT = [
  { applicationNumber: "desc" as const },
] as const satisfies estypes.Sort;
