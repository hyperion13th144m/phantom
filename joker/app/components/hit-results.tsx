"use client";

import { Suspense, useEffect, useState } from "react";
import { useSearchParams, useRouter } from "next/navigation";
import ErrorMessage from "@/app/components/error-message";
import SimpleInput from "@/app/components/simple-input";
import Pagination from "@/app/components/pagination";
import Highlight from "@/app/components/highlight";
import ImagesArray from "@/app/components/images-array";
import { dateTag, buildDocUrl, formatApplicationNumber, formatDate } from "@/lib/helpers";
import { Hit } from "../interfaces/search-results";

interface Props {
    hitResult: Hit;
    keywords?: string;
}

export default function HitResults({ hitResult, keywords }: Props) {
    return hitResult.source && (
        <>
            <div className="bg-gray-100 p-4 rounded-lg shadow-sm">
                <div className="flex justify-between items-center font-extrabold text-lg mb-1.5">
                    <div>
                        {hitResult.source.inventionTitle ?? hitResult.source.documentName ?? "(no title)"}{" "}
                    </div>
                    <div>
                        {hitResult.source.docId && (
                            <a href={`${buildDocUrl(hitResult.source.docId)}?q=${keywords?.split(/ /).join(',')}`}
                                target="_blank" rel="noopener noreferrer" className="ml-2 text-xs">
                                詳細
                            </a>
                        )}
                        <span className="font-normal text-xs text-gray-600">
                            {hitResult.score != null ? ` スコア=${hitResult.score.toFixed(2)}` : ""}
                        </span>
                    </div>
                </div>

                <div className="flex flex-wrap justify-start text-gray-800 text-sm mt-2 gap-4">
                    <div>{formatApplicationNumber(hitResult.source.law ?? "-", hitResult.source.applicationNumber ?? "-")}</div>
                    {
                        hitResult.source.date && (
                            <div>{dateTag(hitResult.source.documentCode)}: {formatDate(hitResult.source.date)}</div>
                        )
                    }
                    <div>{hitResult.source.fileReferenceId ?? "-"}</div>
                    <div>{(hitResult.source.applicants ?? []).join(", ") || "-"}</div>
                </div>
            </div>

            <hr className="my-3 border-gray-300" />

            {/* ハイライトがあれば表示 */}
            {Object.keys(hitResult.highlight || {}).length > 0 && (
                <div className="text-13/1.6">
                    <Highlight highlight={hitResult.highlight || {}} />
                </div>
            )}

            {/* 画像表示 */}
            {hitResult.source && hitResult.source.docId && hitResult.source.images && hitResult.source.images.length > 0 && (
                <div className="mt-3">
                    <ImagesArray docId={hitResult.source.docId} images={hitResult.source.images} />
                </div>
            )}
        </>
    )
}
