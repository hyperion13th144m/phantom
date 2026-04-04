import { z } from "zod";

const stringArraySchema = z
    .array(z.string().trim().min(1).max(200))
    .max(100)
    .transform((arr) => [...new Set(arr.map((s) => s.trim()).filter(Boolean))]);

export const metadataUpdateSchema = z.object({
    assignees: stringArraySchema.optional(),
    tags: stringArraySchema.optional(),
    extraNumbers: stringArraySchema.optional(),
    memo: z.string().max(5000).optional(),
    checked: z.boolean().optional(),
});

export type MetadataUpdateSchema = z.infer<typeof metadataUpdateSchema>;