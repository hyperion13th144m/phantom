"use client";

import { useCallback, useState } from "react";
import type { DocListApiResponse } from "@/interfaces/doc-list-results";
import { buildDocListSearchParams } from "@/lib/doc-list";
import type { DocListQueryParams } from "@/lib/doc-list/schema";

const MAX_RESULTS = 100;

const capResults = (
  groups: DocListApiResponse,
  maxResults: number,
): DocListApiResponse => {
  let remaining = maxResults;

  return groups
    .map((group) => {
      if (remaining <= 0) {
        return { ...group, docs: [] };
      }

      const docs = group.docs.slice(0, remaining);
      remaining -= docs.length;

      return { ...group, docs };
    })
    .filter((group) => group.docs.length > 0);
};

export function useDocListSearch() {
  const [loading, setLoading] = useState(false);
  const [data, setData] = useState<DocListApiResponse | null>(null);
  const [err, setErr] = useState<string | null>(null);
  const [isResultsCapped, setIsResultsCapped] = useState(false);

  const fetchDocList = useCallback(async (params: Partial<DocListQueryParams>) => {
    const usp = buildDocListSearchParams(params);

    setLoading(true);
    setErr(null);

    try {
      const res = await fetch(
        `${process.env.NEXT_PUBLIC_BASE_PATH}/api/docList?${usp.toString()}`,
      );
      if (!res.ok) {
        const errData = await res.json();
        throw new Error(errData.message || "Failed to fetch documents");
      }
      const result = (await res.json()) as DocListApiResponse;
      setData(capResults(result, MAX_RESULTS));
      setIsResultsCapped(res.headers.get("x-results-capped") === "1");
    } catch (e: unknown) {
      setErr((e as Error)?.message ?? String(e));
      setData(null);
      setIsResultsCapped(false);
    } finally {
      setLoading(false);
    }
  }, []);

  return {
    data,
    err,
    fetchDocList,
    isResultsCapped,
    loading,
    maxResults: MAX_RESULTS,
  };
}
