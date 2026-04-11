"use client";

import type { Hit } from "@/interfaces/search-results";
import {
  dateTag,
  formatApplicationNumber,
  formatDate,
  getDocUrl,
} from "@/lib/helpers";
import Highlight from "./highlight";
import ImagesArray from "./images-array";

type Props = {
  hitResult: Hit;
  keywords?: string;
};

export default function HitResults({ hitResult, keywords }: Props) {
  if (!hitResult.source) {
    return null;
  }

  const detailQuery = keywords?.trim()
    ? `?q=${keywords.split(/\s+/).join(",")}`
    : "";

  return (
    <div className="space-y-4">
      <div className="rounded-2xl bg-slate-50 p-4">
        <div className="flex flex-wrap items-start justify-between gap-3">
          <div>
            <div className="text-lg font-semibold text-slate-900">
              {`${hitResult.source.documentName ?? ""} ${hitResult.source.inventionTitle ?? ""}`.trim() ||
                "名称未設定"}
            </div>
            <div className="mt-2 flex flex-wrap gap-2 text-xs text-slate-600">
              <span className="rounded-full bg-white px-2.5 py-1 shadow-sm">
                {formatApplicationNumber(
                  hitResult.source.law ?? "-",
                  hitResult.source.applicationNumber ?? "",
                )}
              </span>
              {hitResult.source.date && (
                <span className="rounded-full bg-white px-2.5 py-1 shadow-sm">
                  {dateTag(hitResult.source.documentCode)}: {formatDate(hitResult.source.date)}
                </span>
              )}
              {hitResult.source.fileReferenceId && (
                <span className="rounded-full bg-white px-2.5 py-1 shadow-sm">
                  整理番号: {hitResult.source.fileReferenceId}
                </span>
              )}
              {hitResult.score != null && (
                <span className="rounded-full bg-white px-2.5 py-1 shadow-sm">
                  スコア {hitResult.score.toFixed(2)}
                </span>
              )}
            </div>
          </div>

          {hitResult.source.docId && (
            <a
              href={`${getDocUrl(hitResult.source.docId)}${detailQuery}`}
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center justify-center rounded-xl border border-slate-300 bg-white px-3 py-2 text-sm font-medium text-slate-700 transition hover:border-slate-400 hover:bg-slate-100"
            >
              詳細を見る
            </a>
          )}
        </div>

        <div className="mt-3 flex flex-wrap gap-2 text-xs text-slate-600">
          {(hitResult.source.extraNumbers ?? []).length > 0 && (
            <span className="rounded-full bg-slate-200 px-2.5 py-1">
              {hitResult.source.extraNumbers?.join(", ")}
            </span>
          )}
          {(hitResult.source.applicants ?? []).map((applicant) => (
            <span key={applicant} className="rounded-full bg-blue-100 px-2.5 py-1 text-blue-800">
              {applicant}
            </span>
          ))}
          {(hitResult.source.tags ?? []).map((tag) => (
            <span key={tag} className="rounded-full bg-slate-200 px-2.5 py-1">
              {tag}
            </span>
          ))}
        </div>
      </div>

      {Object.keys(hitResult.highlight || {}).length > 0 && (
        <Highlight highlight={hitResult.highlight || {}} />
      )}

      {hitResult.source.docId && <ImagesArray docId={hitResult.source.docId} />}
    </div>
  );
}
