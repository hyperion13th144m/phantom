import type { estypes } from "@elastic/elasticsearch";
import { ES_INDEX } from "@/lib/es";
import {
  DOC_LIST_MAX_RESULTS,
  DOC_LIST_SORT,
  DOC_LIST_SOURCE_FIELDS,
} from "@/lib/doc-list/constants";
import type { DocListQueryParams } from "@/lib/doc-list/schema";

function buildInventorQuery(inventors: string): estypes.QueryDslQueryContainer {
  return {
    bool: {
      should: [
        {
          match_phrase: {
            "inventors.ngram": inventors,
          },
        },
      ],
      minimum_should_match: 1,
    },
  };
}

function buildApplicantQuery(applicants: string): estypes.QueryDslQueryContainer {
  return {
    bool: {
      should: [
        {
          match_phrase: {
            "applicants.ngram": applicants,
          },
        },
      ],
      minimum_should_match: 1,
    },
  };
}

function buildApplicationNumberQuery(
  applicationNumber: string,
): estypes.QueryDslQueryContainer {
  return {
    match_phrase: {
      "applicationNumber.ngram": applicationNumber,
    },
  };
}

function buildFileReferenceIdQuery(
  fileReferenceId: string,
): estypes.QueryDslQueryContainer {
  return {
    bool: {
      should: [
        {
          match_phrase: {
            "fileReferenceId.ngram": fileReferenceId,
          },
        },
        {
          match_phrase: {
            "extraNumbers.ngram": fileReferenceId,
          },
        },
      ],
      minimum_should_match: 1,
    },
  };
}

function buildLawQuery(law: string): estypes.QueryDslQueryContainer {
  return {
    match: {
      law: {
        query: law,
        fuzziness: "AUTO",
        operator: "and",
      },
    },
  };
}

function buildMustQueries(
  params: DocListQueryParams,
): estypes.QueryDslQueryContainer[] {
  const must: estypes.QueryDslQueryContainer[] = [];

  if (params.inventors) {
    must.push(buildInventorQuery(params.inventors));
  }
  if (params.applicants) {
    must.push(buildApplicantQuery(params.applicants));
  }
  if (params.applicationNumber) {
    must.push(buildApplicationNumberQuery(params.applicationNumber));
  }
  if (params.fileReferenceId) {
    must.push(buildFileReferenceIdQuery(params.fileReferenceId));
  }
  if (params.law) {
    must.push(buildLawQuery(params.law));
  }

  return must;
}

export function buildDocListSearchRequest(
  params: DocListQueryParams,
): estypes.SearchRequest {
  const must = buildMustQueries(params);

  return {
    index: ES_INDEX,
    size: DOC_LIST_MAX_RESULTS,
    track_total_hits: true,
    query: {
      bool: {
        must: must.length > 0 ? must : [{ match_all: {} }],
      },
    },
    sort: [...DOC_LIST_SORT],
    _source: [...DOC_LIST_SOURCE_FIELDS],
  };
}
