import {
  ApiResponseError,
  PatentDocumentSource,
} from "@/interfaces/search-results";
import { es } from "@/lib/es";
import {
  buildSearchRequest,
  logSearchFailure,
  logSearchRequest,
  logSearchSuccess,
  parseSearchParams,
  toSearchApiResponse,
} from "@/lib/search";
import { NextRequest, NextResponse } from "next/server";

export const runtime = "nodejs";

export async function GET(req: NextRequest) {
  const parsed = parseSearchParams(req.nextUrl.searchParams);

  if (!parsed.success) {
    return NextResponse.json(
      { error: parsed.error.flatten() },
      { status: 400 },
    );
  }

  const params = parsed.data;

  logSearchRequest(params, req.url);

  try {
    const result = await es.search<PatentDocumentSource>(
      buildSearchRequest(params),
    );
    const response = toSearchApiResponse(result, params);

    logSearchSuccess(params, response);

    return NextResponse.json(response);
  } catch (error: unknown) {
    logSearchFailure(params, error);

    return NextResponse.json(
      {
        error: "Elasticsearch search failed",
        message: (error as Error)?.message ?? String(error),
      } as ApiResponseError,
      { status: 500 },
    );
  }
}
