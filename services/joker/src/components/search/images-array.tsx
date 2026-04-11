"use client";

import Image from "next/image";
import { useEffect, useState } from "react";
import { ImagesInformation } from "@/interfaces/generated/images-information";
import { getImageUrl } from "@/lib/helpers";

type Props = {
  docId: string;
  thumbnailTag?: string;
  largeTag?: string;
};

type ImageItem = {
  number: string;
  filename: string;
  kind: string;
  sizeTag: string;
  width: number;
  height: number;
  description: string;
  representative: boolean;
};

const flattenImages = (images: ImagesInformation): ImageItem[] => {
  return images.derived.map((derived) => ({
    number: images.number || "",
    filename: derived.filename,
    kind: images.kind,
    sizeTag:
      derived.attributes?.find((attr) => attr.key === "sizeTag")?.value || "",
    width: derived.width,
    height: derived.height,
    description: images.description || "",
    representative: images.representative || false,
  }));
};

export default function ImagesArray({
  docId,
  thumbnailTag = "thumbnail",
  largeTag = "middle",
}: Props) {
  const [selectedImage, setSelectedImage] = useState<number | null>(null);
  const [thumbnails, setThumbnails] = useState<ImageItem[]>([]);
  const [largeImages, setLargeImages] = useState<ImageItem[]>([]);

  useEffect(() => {
    const fetchImages = async () => {
      const basePath = process.env.NEXT_PUBLIC_BASE_PATH ?? "";
      const res = await fetch(basePath + "/api/images/" + docId);
      if (!res.ok) {
        console.error("Failed to fetch images information");
        return;
      }

      const data: ImagesInformation[] = await res.json();
      const figures = data
        .filter((img) => img.kind === "figures")
        .flatMap(flattenImages);

      setThumbnails(
        figures
          .filter((img) => img.sizeTag === thumbnailTag)
          .sort((a, b) => a.filename.localeCompare(b.filename)),
      );
      setLargeImages(
        figures
          .filter((img) => img.sizeTag === largeTag)
          .sort((a, b) => a.filename.localeCompare(b.filename)),
      );
    };

    fetchImages();
  }, [docId, largeTag, thumbnailTag]);

  if (thumbnails.length === 0) {
    return null;
  }

  return (
    <>
      <div className="flex flex-wrap gap-3">
        {thumbnails.map((img, idx) => (
          <div
            key={img.filename}
            className="rounded-2xl border border-slate-200 bg-white p-2 shadow-sm"
          >
            <button
              onClick={() => setSelectedImage(idx)}
              className="transition-opacity hover:opacity-80"
            >
              <Image
                src={getImageUrl(docId, img.filename)}
                alt={img.description || `Image ${img.number}`}
                className="max-h-[120px] max-w-[120px] object-contain"
                width={img.width || 120}
                height={img.height || 120}
                unoptimized
              />
            </button>
            <div className="mt-1 text-center text-xs text-slate-600">
              図{img.number}
              {img.representative && <span className="text-blue-600"> ★</span>}
            </div>
          </div>
        ))}
      </div>

      {selectedImage !== null && largeImages[selectedImage] && (
        <div
          className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4"
          onClick={() => setSelectedImage(null)}
        >
          <div
            className="relative max-h-[90vh] max-w-[90vw] overflow-auto rounded-3xl bg-white shadow-xl"
            onClick={(e) => e.stopPropagation()}
          >
            <button
              onClick={() => setSelectedImage(null)}
              className="absolute right-3 top-3 z-10 flex h-9 w-9 items-center justify-center rounded-full bg-white shadow-md transition hover:bg-slate-100"
              aria-label="閉じる"
            >
              ✕
            </button>
            <div className="p-5">
              <Image
                src={getImageUrl(docId, largeImages[selectedImage].filename)}
                alt={
                  largeImages[selectedImage].description ||
                  `Image ${largeImages[selectedImage].number}`
                }
                className="h-auto max-w-full"
                width={largeImages[selectedImage].width || 1200}
                height={largeImages[selectedImage].height || 1200}
                unoptimized
              />
              <div className="mt-4 text-center">
                <div className="font-semibold text-slate-900">
                  図{largeImages[selectedImage].number}
                </div>
                {largeImages[selectedImage].description && (
                  <div className="mt-1 text-sm text-slate-600">
                    {largeImages[selectedImage].description}
                  </div>
                )}
                {largeImages[selectedImage].representative && (
                  <span className="mt-2 inline-block rounded-full bg-blue-100 px-2.5 py-1 text-xs text-blue-800">
                    代表図
                  </span>
                )}
              </div>
            </div>
          </div>
        </div>
      )}
    </>
  );
}
