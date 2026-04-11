// Public entrypoint for the search module.
// Import from `@/lib/search` outside this directory, and prefer direct relative module imports inside it.
export { logSearchFailure, logSearchRequest, logSearchSuccess } from "@/lib/search/logging";
export { buildSearchRequest } from "@/lib/search/query";
export { toSearchApiResponse } from "@/lib/search/response";
export { parseSearchParams } from "@/lib/search/schema";
