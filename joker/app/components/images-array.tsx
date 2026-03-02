"use client";

import { useState } from "react";
import { ImageInformation } from "@/app/interfaces/search-results";
import { buildImageUrl } from "@/lib/helpers";

interface Props {
    docId: string;
    images: ImageInformation[];
    thumbnailTag?: string;
    largeTag?: string;
}

const ImagesArray: React.FC<Props> = ({ docId, images, thumbnailTag = "thumbnail", largeTag = "middle" }) => {
    const [selectedImage, setSelectedImage] = useState<number | null>(null);
    const figures = images.filter(img => img.kind === "figures");
    const thumbnails = figures
        .filter(img => img.sizeTag === thumbnailTag)
        .sort((a, b) => a.filename.localeCompare(b.filename));
    const largeImages = figures
        .filter(img => img.sizeTag === largeTag)
        .sort((a, b) => a.filename.localeCompare(b.filename));
    return (
        <>
            <div className="flex flex-wrap gap-2">
                {thumbnails.map((img, idx) => (
                    <div key={img.filename}
                        className="border border-gray-300 rounded p-1">
                        <button
                            onClick={() => setSelectedImage(idx)}
                            className="cursor-pointer hover:opacity-80 transition-opacity"
                        >
                            <img
                                src={buildImageUrl(docId, img.filename)}
                                alt={img.description || `Image ${img.number}`}
                                className="max-w-[120px] max-h-[120px] object-contain"
                                width={img.width}
                                height={img.height}
                                onError={(e) => {
                                    // 画像読み込みエラー時の代替表示
                                    (e.target as HTMLImageElement).style.display = "none";
                                }}
                            />
                        </button>
                        <div className="text-center text-xs text-gray-600 mt-1">
                            図{img.number}
                            {img.representative && <span className="text-blue-600"> ★</span>}
                        </div>
                    </div>
                ))}
            </div>

            {/* ドロワー */}
            {selectedImage !== null && (
                <div
                    className="fixed inset-0 z-50 flex items-center justify-center bg-black/50"
                    onClick={() => setSelectedImage(null)}
                >
                    <div
                        className="relative bg-white rounded-lg shadow-lg max-w-[90vw] max-h-[90vh] overflow-auto"
                        onClick={(e) => e.stopPropagation()}
                    >
                        <button
                            onClick={() => setSelectedImage(null)}
                            className="absolute top-2 right-2 bg-white rounded-full w-8 h-8 flex items-center justify-center shadow-md hover:bg-gray-100 transition-colors z-10"
                            aria-label="閉じる"
                        >
                            ✕
                        </button>
                        <div className="p-4">
                            <img
                                src={buildImageUrl(docId, largeImages[selectedImage].filename)}
                                alt={largeImages[selectedImage].description || `Image ${largeImages[selectedImage].number}`}
                                className="max-w-full h-auto"
                            />
                            <div className="mt-4 text-center">
                                <div className="font-semibold">図{largeImages[selectedImage].number}</div>
                                {largeImages[selectedImage].description && (
                                    <div className="text-sm text-gray-600 mt-1">
                                        {largeImages[selectedImage].description}
                                    </div>
                                )}
                                {largeImages[selectedImage].representative && (
                                    <span className="inline-block mt-2 px-2 py-1 bg-blue-100 text-blue-800 text-xs rounded">
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
};

export default ImagesArray;
