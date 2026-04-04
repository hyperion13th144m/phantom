import { z } from "zod";

export const metadataSyncSchema = z
    .object({
        docIds: z.array(z.string().trim().min(1)).max(1000).optional(),
        allFailed: z.boolean().optional(),
        allPending: z.boolean().optional(),
        limit: z.number().int().min(1).max(5000).optional(),
        batchSize: z.number().int().min(1).max(1000).optional(),
    })
    .refine(
        (value) =>
            (value.docIds && value.docIds.length > 0) ||
            value.allFailed === true ||
            value.allPending === true,
        {
            message: "Specify docIds, allFailed, or allPending",
        },
    );

export type MetadataSyncSchema = z.infer<typeof metadataSyncSchema>;