import { z } from "zod";

export const SearchQuerySchema = z.object({
  q: z.string().optional(),
  page: z.coerce.number().int().min(1).default(1),
  size: z.coerce.number().int().min(1).max(100).default(25),
  applicant: z.string().optional(),
  inventor: z.string().optional(),
  assignee: z.string().optional(),
  tag: z.string().optional(),
  documentName: z.string().optional(),
  specialMentionMatterArticle: z.string().optional(),
  rejectionReasonArticle: z.string().optional(),
  priorityClaims: z.string().optional(),
  withHighlight: z.boolean().optional(),
});

export type SearchQueryParams = z.infer<typeof SearchQuerySchema>;

export function parseSearchParams(searchParams: URLSearchParams) {
  return SearchQuerySchema.safeParse({
    q: searchParams.get("q") ?? undefined,
    page: searchParams.get("page") ?? undefined,
    size: searchParams.get("size") ?? undefined,
    applicant: searchParams.get("applicant") ?? undefined,
    inventor: searchParams.get("inventor") ?? undefined,
    assignee: searchParams.get("assignee") ?? undefined,
    tag: searchParams.get("tag") ?? undefined,
    documentName: searchParams.get("documentName") ?? undefined,
    specialMentionMatterArticle:
      searchParams.get("specialMentionMatterArticle") ?? undefined,
    rejectionReasonArticle:
      searchParams.get("rejectionReasonArticle") ?? undefined,
    priorityClaims: searchParams.get("priorityClaims") ?? undefined,
    withHighlight: searchParams.get("withHighlight") === "true" ? true : undefined,
  });
}
