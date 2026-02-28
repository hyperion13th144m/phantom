import fs from "node:fs/promises";
import path from "node:path";
import type { CarouselImage } from "~/interfaces/carousel-images";
import type { ImagesInformation } from "~/interfaces/generated/images-information";
import { getContentRoot } from "~/lib/path-funcs";


export const getCarouselImage = async (docId: string, kind: string, sizeTag: string): Promise<CarouselImage[]> => {
    const imagesPath = path.join(getContentRoot(docId), "json/images-information.json");
    const imagesRaw = await fs.readFile(imagesPath, "utf-8");
    const images: ImagesInformation[] = JSON.parse(imagesRaw);
    return images
        .filter((img) => img.kind === kind)
        .map((img) => {
            const derived = img.derived
                .find((d) => d.attributes?.some((attr) => attr.key === "sizeTag" && attr.value === sizeTag));
            if (derived) {
                return {
                    filename: derived.filename,
                    width: derived.width,
                    height: derived.height,
                    description: img.description,
                } as CarouselImage;
            } else {
                return null;
            }
        })
        .filter((img): img is CarouselImage => img !== null);
}