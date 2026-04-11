"use client";

import { useState } from "react";
import type {
  DocListApiResponse,
  DocListDocument,
  DocListGroup,
} from "@/interfaces/doc-list-results";
import {
  dateTag,
  formatApplicationNumber,
  formatDate,
  getDocUrl,
} from "@/lib/helpers";

type Props = {
  data: DocListApiResponse;
  isResultsCapped: boolean;
  maxResults: number;
};

type DocumentTone = {
  accentClassName: string;
  badgeClassName: string;
  label: string;
};

const DEFAULT_VISIBLE_DOCS = 4;

const getFileReferenceId = (group: DocListGroup): string[] => {
  const set = new Set<string>();
  group.docs.forEach((doc) => {
    if (doc.fileReferenceId.trim()) {
      set.add(doc.fileReferenceId.trim());
    }
    doc.extraNumbers?.forEach((num) => {
      if (num.trim()) {
        set.add(num.trim());
      }
    });
  });
  return Array.from(set);
};

const getApplicants = (group: DocListGroup): string[] => {
  const applicantsSet = new Set<string>();
  group.docs.forEach((doc) => {
    doc.applicants.forEach((applicant) => {
      if (applicant.trim()) {
        applicantsSet.add(applicant.trim());
      }
    });
  });
  return Array.from(applicantsSet);
};

const sortDocs = (docs: DocListDocument[]): DocListDocument[] => {
  return [...docs].sort((a, b) => {
    const dateA = a.date ? Number(a.date) : 0;
    const dateB = b.date ? Number(b.date) : 0;
    return dateA - dateB;
  });
};

function getDocumentTone(doc: DocListDocument): DocumentTone {
  const tag = dateTag(doc.documentCode);

  if (tag === "出願日") {
    return {
      accentClassName: "border-l-4 border-l-emerald-500",
      badgeClassName: "bg-emerald-100 text-emerald-800",
      label: "出願関連",
    };
  }

  if (tag === "発送日") {
    return {
      accentClassName: "border-l-4 border-l-blue-500",
      badgeClassName: "bg-blue-100 text-blue-800",
      label: "発送関連",
    };
  }

  return {
    accentClassName: "border-l-4 border-l-amber-500",
    badgeClassName: "bg-amber-100 text-amber-800",
    label: "提出関連",
  };
}

function EmptyState() {
  return (
    <div className="rounded-3xl border border-dashed border-slate-300 bg-white px-6 py-12 text-center shadow-sm">
      <div className="mx-auto flex h-14 w-14 items-center justify-center rounded-2xl bg-slate-100 text-slate-500">
        0件
      </div>
      <h3 className="mt-5 text-lg font-semibold text-slate-900">
        条件に一致する文書は見つかりませんでした
      </h3>
      <p className="mx-auto mt-2 max-w-2xl text-sm leading-6 text-slate-600">
        発明者名や出願人名の表記ゆれ、出願番号の形式、法律種別の指定を見直すと結果が見つかることがあります。
        条件を少し広げて再検索してみてください。
      </p>
      <div className="mt-6 flex flex-wrap items-center justify-center gap-2 text-xs font-medium text-slate-500">
        <span className="rounded-full bg-slate-100 px-3 py-1">表記ゆれを確認</span>
        <span className="rounded-full bg-slate-100 px-3 py-1">条件を減らす</span>
        <span className="rounded-full bg-slate-100 px-3 py-1">法律種別を外す</span>
      </div>
    </div>
  );
}

type GroupCardProps = {
  group: DocListGroup;
  groupIdx: number;
};

function GroupCard({ group, groupIdx }: GroupCardProps) {
  const [isExpanded, setIsExpanded] = useState(false);
  const applicants = getApplicants(group);
  const fileReferenceIds = getFileReferenceId(group);
  const docs = sortDocs(group.docs);
  const hasMoreDocs = docs.length > DEFAULT_VISIBLE_DOCS;
  const visibleDocs = isExpanded ? docs : docs.slice(0, DEFAULT_VISIBLE_DOCS);

  return (
    <article className="overflow-hidden rounded-3xl border border-slate-200 bg-white shadow-sm">
      <div className="border-b border-slate-200 bg-gradient-to-r from-blue-50 to-white px-6 py-5">
        <div className="flex flex-wrap items-start justify-between gap-4">
          <div>
            <div className="text-xs font-medium uppercase tracking-[0.2em] text-blue-700">
              Application
            </div>
            <h2 className="mt-2 text-xl font-semibold text-slate-900">
              {formatApplicationNumber(group.law, group.applicationNumber) ||
                "（未設定）"}
            </h2>
          </div>
          <div className="flex flex-wrap items-center gap-2">
            <div className="rounded-full bg-white px-3 py-1 text-xs font-medium text-slate-600 shadow-sm">
              文書 {group.docs.length} 件
            </div>
            <div className="rounded-full bg-blue-100 px-3 py-1 text-xs font-medium text-blue-800">
              #{groupIdx + 1}
            </div>
          </div>
        </div>

        {fileReferenceIds.length > 0 && (
          <div className="mt-4 text-sm text-slate-600">
            <span className="font-medium text-slate-700">整理番号:</span>{" "}
            {fileReferenceIds.join(", ")}
          </div>
        )}

        {applicants.length > 0 && (
          <div className="mt-4 flex flex-wrap gap-2">
            {applicants.map((applicant, appIdx) => (
              <span
                key={applicant + "-" + appIdx}
                className="rounded-full bg-blue-100 px-3 py-1 text-xs font-medium text-blue-800"
              >
                {applicant}
              </span>
            ))}
          </div>
        )}
      </div>

      <div className="px-6 py-5">
        <ol className="space-y-3">
          {visibleDocs.map((doc, docIdx) => {
            const tone = getDocumentTone(doc);

            return (
              <li
                key={doc.docId + "-" + docIdx}
                className={
                  tone.accentClassName +
                  " rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3"
                }
              >
                <div className="flex flex-wrap items-start justify-between gap-3">
                  <div className="min-w-0 flex-1">
                    <div className="mb-2 flex flex-wrap items-center gap-2">
                      <span
                        className={
                          tone.badgeClassName +
                          " rounded-full px-2.5 py-1 text-[11px] font-semibold"
                        }
                      >
                        {tone.label}
                      </span>
                      <span className="text-xs text-slate-500">
                        {dateTag(doc.documentCode)}
                      </span>
                    </div>
                    <a
                      className="text-sm font-semibold text-blue-700 hover:text-blue-800 hover:underline"
                      href={getDocUrl(doc.docId)}
                    >
                      {doc.documentName}
                    </a>
                    {doc.date && (
                      <div className="mt-1 text-xs text-slate-500">
                        {dateTag(doc.documentCode)}: {formatDate(doc.date)}
                      </div>
                    )}
                  </div>
                  <div className="rounded-full bg-white px-2.5 py-1 text-xs font-medium text-slate-500 shadow-sm">
                    {docIdx + 1}
                  </div>
                </div>
              </li>
            );
          })}
        </ol>

        {hasMoreDocs && (
          <div className="mt-4 flex items-center justify-between gap-3 rounded-2xl bg-slate-50 px-4 py-3">
            <div className="text-sm text-slate-600">
              {isExpanded
                ? "すべての文書を表示中です"
                : "残り " + (docs.length - DEFAULT_VISIBLE_DOCS) + " 件の文書があります"}
            </div>
            <button
              type="button"
              onClick={() => setIsExpanded((current) => !current)}
              className="inline-flex items-center justify-center rounded-xl border border-slate-300 bg-white px-3 py-2 text-sm font-semibold text-slate-700 transition hover:border-slate-400 hover:bg-slate-100"
            >
              {isExpanded ? "折りたたむ" : "さらに表示"}
            </button>
          </div>
        )}
      </div>
    </article>
  );
}

export default function DocListResults({
  data,
  isResultsCapped,
  maxResults,
}: Props) {
  const totalDocs = data.reduce((sum, group) => sum + group.docs.length, 0);

  return (
    <section className="space-y-6">
      <div className="rounded-2xl border border-slate-200 bg-slate-50 px-5 py-4">
        <div className="flex flex-wrap items-center justify-between gap-3">
          <div className="text-sm text-slate-700">
            {data.length === 0 ? (
              <span>検索結果がありません</span>
            ) : (
              <span>
                <span className="font-semibold text-slate-900">{data.length}</span>
                件の特許出願、
                <span className="font-semibold text-slate-900">{totalDocs}</span>
                件の文書が見つかりました
              </span>
            )}
          </div>
          <div className="rounded-full bg-white px-3 py-1 text-xs font-medium text-slate-600 shadow-sm">
            文書数ベースで集計
          </div>
        </div>
        {isResultsCapped && (
          <p className="mt-3 rounded-xl border border-amber-200 bg-amber-50 px-3 py-2 text-sm text-amber-800">
            検索結果は最大{maxResults}件まで表示しています。条件を絞って再検索してください。
          </p>
        )}
      </div>

      {data.length === 0 ? (
        <EmptyState />
      ) : (
        <div className="grid gap-6 xl:grid-cols-2">
          {data.map((group, groupIdx) => (
            <GroupCard
              key={group.law + "-" + group.applicationNumber + "-" + groupIdx}
              group={group}
              groupIdx={groupIdx}
            />
          ))}
        </div>
      )}
    </section>
  );
}
