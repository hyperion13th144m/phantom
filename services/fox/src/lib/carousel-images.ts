import type { CarouselImage } from "~/interfaces/carousel-images";
import type { ImagesInformation } from "~/interfaces/generated/images-information";
import { getImageUrl } from "./path-funcs";

export const getCarouselImage = async (docId: string, kind: string, sizeTag: string, origin: string): Promise<CarouselImage[]> => {
    try {
        const res = await fetch(`${origin}/api/${docId}/images-information`);
        if (!res.ok) throw new Error(`API Error: ${res.status}`);
        const images: ImagesInformation[] = await res.json();
        return images
            .filter((img) => img.kind === kind)
            .map((img) => {
                const derived = img.derived
                    .find((d) => d.attributes?.some((attr) => attr.key === "sizeTag" && attr.value === sizeTag));
                if (derived) {
                    const url = getImageUrl(docId, derived.filename);
                    return {
                        filename: url,
                        width: derived.width,
                        height: derived.height,
                        description: img.description,
                    } as CarouselImage;
                } else {
                    return null;
                }
            })
            .filter((img): img is CarouselImage => img !== null);
    } catch (err) {
        console.error(err);
        return [];
    }
}