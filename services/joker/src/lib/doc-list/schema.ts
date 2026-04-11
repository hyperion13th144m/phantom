import { z } from "zod";

export const DocListQuerySchema = z.object({
  applicants: z.string().optional(),
  inventors: z.string().optional(),
  applicationNumber: z.string().optional(),
  fileReferenceId: z.string().optional(),
  law: z.string().optional(),
});

export type DocListQueryParams = z.infer<typeof DocListQuerySchema>;

function normalizeQueryValue(value?: string | null) {
  const normalized = value?.trim();
  return normalized ? normalized : undefined;
}

export function normalizeDocListQueryParams(
  params: Partial<Record<keyof DocListQueryParams, string | null | undefined>>,
): DocListQueryParams {
  return {
    applicants: normalizeQueryValue(params.applicants),
    inventors: normalizeQueryValue(params.inventors),
    applicationNumber: normalizeQueryValue(params.applicationNumber),
    fileReferenceId: normalizeQueryValue(params.fileReferenceId),
    law: normalizeQueryValue(params.law),
  };
}

export function buildDocListSearchParams(
  params: Partial<Record<keyof DocListQueryParams, string | null | undefined>>,
) {
  const normalized = normalizeDocListQueryParams(params);
  const searchParams = new URLSearchParams();

  Object.entries(normalized).forEach(([key, value]) => {
    if (value) {
      searchParams.set(key, value);
    }
  });

  return searchParams;
}

export function parseDocListSearchParams(searchParams: URLSearchParams) {
  return DocListQuerySchema.safeParse(
    normalizeDocListQueryParams({
      applicants: searchParams.get("applicants"),
      inventors: searchParams.get("inventors"),
      applicationNumber: searchParams.get("applicationNumber"),
      fileReferenceId: searchParams.get("fileReferenceId"),
      law: searchParams.get("law"),
    }),
  );
}

export function hasDocListCriteria(params: DocListQueryParams) {
  return Boolean(
    params.applicants ||
      params.inventors ||
      params.applicationNumber ||
      params.fileReferenceId ||
      params.law,
  );
}
