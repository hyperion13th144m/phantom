import { isApplicationBody } from "~/interfaces/generated/application-body.guard";
import { isAttachingDocument } from "~/interfaces/generated/attaching-document.guard";
import { isCpyNtcPtERn } from "~/interfaces/generated/cpy-ntc-pt-e-rn.guard";
import { isCpyNtcPtE } from "~/interfaces/generated/cpy-ntc-pt-e.guard";
import { isCpyNtcPtF } from "~/interfaces/generated/cpy-ntc-pt-f.guard";
import { isForeignLanguageBody } from "~/interfaces/generated/foreign-language-body.guard";
import type { ImagesInformation } from "~/interfaces/generated/images-information";
import { isPatAmnd } from "~/interfaces/generated/pat-amnd.guard";
import { isPatAppDoc } from "~/interfaces/generated/pat-appd.guard";
import { isPatEtc } from "~/interfaces/generated/pat-etc.guard";
import { isPatRspn } from "~/interfaces/generated/pat-rspn.guard";
import { getImageUrl } from "./path-funcs";

const order = [
    isPatAppDoc,
    isApplicationBody,
    isForeignLanguageBody,
    isPatRspn,
    isPatEtc,
    isPatAmnd,
    isCpyNtcPtF,
    isCpyNtcPtE,
    isCpyNtcPtERn,
    isAttachingDocument,
];

export const getDocument = async (docId: string, origin: string, imageSizeTag: string = "large") => {
    let json: any[] = [];
    try {
        const res = await fetch(`${origin}/api/${docId}/content`);
        if (!res.ok) throw new Error(`API Error: ${res.status}`);
        json = await res.json();
    } catch (err) {
        console.error(err);
    }

    try {
        const imageMeta = await fetchImageMetadata(docId, imageSizeTag, origin);
        hydrateImageContainers(json, imageMeta);
    } catch (err) {
        console.error(err);
    }

    const sortedJson = order
        .map((guard) => json.find((b: any) => guard(b)))
        .filter((b): b is NonNullable<typeof b> => b !== undefined);
    return sortedJson;
}

type ResolvedImageInfo = {
    url: string;
    width: number;
    height: number;
    alt: string;
};

const fetchImageMetadata = async (docId: string, sizeTag: string, origin: string) => {
    const res = await fetch(`${origin}/api/${docId}/images-information`);
    if (!res.ok) throw new Error(`API Error: ${res.status}`);
    const images: ImagesInformation[] = await res.json();

    const meta = new Map<string, ResolvedImageInfo>();
    for (const img of images) {
        const derived = img.derived.find((d) =>
            d.attributes?.some(
                (attr) => attr.key === "sizeTag" && attr.value === sizeTag,
            ),
        );
        if (!derived) continue;

        const url = getImageUrl(docId, derived.filename);
        meta.set(img.filename, {
            url,
            width: derived.width,
            height: derived.height,
            alt: img.description || "",
        });
    }
    return meta;
};

const hydrateImageContainers = (
    node: unknown,
    meta: Map<string, ResolvedImageInfo>,
) => {
    if (Array.isArray(node)) {
        node.forEach((item) => hydrateImageContainers(item, meta));
        return;
    }

    if (!node || typeof node !== "object") return;

    const record = node as Record<string, unknown>;
    if (record.tag === "image-container" && typeof record.file === "string") {
        const resolved = meta.get(record.file);
        if (resolved) {
            record.url = resolved.url;
            record.width = resolved.width;
            record.height = resolved.height;
            record.alt = resolved.alt;
        }
    }

    if (Array.isArray(record.blocks)) {
        record.blocks.forEach((item) => hydrateImageContainers(item, meta));
    }
};
