import { z } from "zod";

const stringArraySchema = z
    .array(z.string().trim().min(1).max(200))
    .max(100)
    .transform((arr) => [...new Set(arr.map((s) => s.trim()).filter(Boolean))]);

export const metadataBulkUpdateSchema = z.object({
    docIds: z.array(z.string().trim().min(1)).min(1).max(1000),

    patch: z
        .object({
            tagsToAdd: stringArraySchema.optional(),
            assigneesToAdd: stringArraySchema.optional(),
            extraNumbersToAdd: stringArraySchema.optional(),
            checked: z.boolean().optional(),
            memoAppend: z.string().max(5000).optional(),
        })
        .refine(
            (patch) =>
                Boolean(
                    (patch.tagsToAdd && patch.tagsToAdd.length > 0) ||
                    (patch.assigneesToAdd && patch.assigneesToAdd.length > 0) ||
                    (patch.extraNumbersToAdd && patch.extraNumbersToAdd.length > 0) ||
                    typeof patch.checked === "boolean" ||
                    (patch.memoAppend && patch.memoAppend.trim().length > 0),
                ),
            {
                message: "patch must contain at least one operation",
            },
        ),
});

export type MetadataBulkUpdateSchema = z.infer<
    typeof metadataBulkUpdateSchema
>;