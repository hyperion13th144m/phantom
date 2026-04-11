import type { estypes } from "@elastic/elasticsearch";
import type {
  DocListApiResponse,
  DocListDocument,
  DocListGroup,
  DocListSource,
} from "@/interfaces/doc-list-results";
import { DOC_LIST_MAX_RESULTS } from "@/lib/doc-list/constants";

type SearchResult = estypes.SearchResponse<DocListSource>;

export interface DocListResponseMeta {
  totalHits: number;
  returnedHits: number;
  groupCount: number;
  isResultsCapped: boolean;
}

function toStringArray(value: string[] | string | undefined): string[] {
  if (Array.isArray(value)) {
    return value;
  }
  return value ? [value] : [];
}

function toDoc(hit: estypes.SearchHit<DocListSource>): DocListDocument {
  const source = hit._source ?? {};

  return {
    docId: source.docId || hit._id || "",
    applicants: toStringArray(source.applicants),
    fileReferenceId: source.fileReferenceId || "",
    date: source.date || "",
    documentName: source.documentName || "",
    documentCode: source.documentCode || "",
    extraNumbers: toStringArray(source.extraNumbers),
  };
}

function getGroupKey(source: DocListSource): string {
  return `${source.law || ""}|${source.applicationNumber || ""}`;
}

function getTotalHits(result: SearchResult): number {
  return typeof result.hits.total === "number"
    ? result.hits.total
    : (result.hits.total?.value ?? result.hits.hits.length);
}

export function toDocListApiResponse(result: SearchResult): {
  groups: DocListApiResponse;
  meta: DocListResponseMeta;
} {
  const hits = result.hits.hits ?? [];
  const totalHits = getTotalHits(result);
  const isResultsCapped = totalHits > DOC_LIST_MAX_RESULTS;
  const groupMap = new Map<string, DocListGroup>();
  const groupOrder: string[] = [];

  hits.forEach((hit) => {
    const source = hit._source ?? {};
    const key = getGroupKey(source);

    if (!groupMap.has(key)) {
      groupMap.set(key, {
        law: source.law || "",
        applicationNumber: source.applicationNumber || "",
        docs: [],
      });
      groupOrder.push(key);
    }

    groupMap.get(key)?.docs.push(toDoc(hit));
  });

  const groups = groupOrder.map((key) => groupMap.get(key)!).filter(Boolean);

  return {
    groups,
    meta: {
      totalHits,
      returnedHits: hits.length,
      groupCount: groups.length,
      isResultsCapped,
    },
  };
}
