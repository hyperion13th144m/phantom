import { z } from "zod";

export const metadataRestoreSchema = z
    .object({
        all: z.boolean().optional(),
        docIds: z.array(z.string().trim().min(1)).max(5000).optional(),
        limit: z.number().int().min(1).max(10000).optional(),
        offset: z.number().int().min(0).optional(),
        batchSize: z.number().int().min(1).max(1000).optional(),
    })
    .refine(
        (value) => value.all === true || (value.docIds && value.docIds.length > 0),
        {
            message: "Specify all=true or docIds",
        },
    );