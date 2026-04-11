import { useCallback, useState } from "react";
import type {
  ApiResponse,
  ApiResponseError,
  ApiResponseSuccess,
} from "@/interfaces/search-results";
import { buildSearchParams, type SearchQuery } from "./state";

export function useSearch() {
  const [loading, setLoading] = useState(false);
  const [data, setData] = useState<ApiResponseSuccess | null>(null);
  const [err, setErr] = useState<string | null>(null);

  const fetchSearch = useCallback(async (query: SearchQuery) => {
    const params = buildSearchParams(query);
    const basePath = process.env.NEXT_PUBLIC_BASE_PATH ?? "";

    setLoading(true);
    setErr(null);
    try {
      const res = await fetch(`${basePath}/api/search?${params.toString()}`, {
        method: "GET",
        headers: { "Content-Type": "application/json" },
      });
      const json: ApiResponse = await res.json();
      if (!res.ok) {
        const error = json as ApiResponseError;
        throw new Error(error?.message || error?.error || `HTTP ${res.status}`);
      }
      setData(json as ApiResponseSuccess);
    } catch (error: unknown) {
      setErr((error as Error)?.message ?? String(error));
      setData(null);
    } finally {
      setLoading(false);
    }
  }, []);

  return {
    data,
    err,
    fetchSearch,
    loading,
  };
}
