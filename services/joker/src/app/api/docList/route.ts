import type { DocListApiError, DocListSource } from "@/interfaces/doc-list-results";
import { getEsClient } from "@/lib/es";
import {
  buildDocListSearchRequest,
  DOC_LIST_MAX_RESULTS,
  hasDocListCriteria,
  logDocListFailure,
  logDocListRequest,
  logDocListSuccess,
  parseDocListSearchParams,
  toDocListApiResponse,
} from "@/lib/doc-list";
import { NextRequest, NextResponse } from "next/server";

export const runtime = "nodejs";

export async function GET(req: NextRequest) {
  const parsed = parseDocListSearchParams(req.nextUrl.searchParams);

  if (!parsed.success) {
    return NextResponse.json(
      { error: parsed.error.flatten() },
      { status: 400 },
    );
  }

  const params = parsed.data;

  logDocListRequest(params, req.url);

  if (!hasDocListCriteria(params)) {
    return NextResponse.json(
      {
        error: "Bad Request",
        message:
          "At least one of applicants, inventors, applicationNumber, fileReferenceId, or law parameter is required",
      } as DocListApiError,
      { status: 400 },
    );
  }

  try {
    const result = await (await getEsClient()).search<DocListSource>(buildDocListSearchRequest(params));
    const { groups, meta } = toDocListApiResponse(result);

    logDocListSuccess(params, meta);

    const response = NextResponse.json(groups);
    response.headers.set("X-Results-Capped", meta.isResultsCapped ? "1" : "0");
    response.headers.set("X-Results-Limit", String(DOC_LIST_MAX_RESULTS));
    response.headers.set("X-Total-Hits", String(meta.totalHits));

    return response;
  } catch (error: unknown) {
    logDocListFailure(params, error);

    return NextResponse.json(
      {
        error: "Elasticsearch search failed",
        message: (error as Error)?.message ?? String(error),
      } as DocListApiError,
      { status: 500 },
    );
  }
}
