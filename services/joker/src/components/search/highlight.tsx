"use client";

type Props = {
  highlight: Record<string, string[]>;
};

const fieldDisplayNames: Record<string, string> = {
  independentClaims: "【独立請求項】",
  dependentClaims: "【従属請求項】",
  abstract: "【要約】",
  draftingBody: "【拒絶理由】",
  opinionContentsArticle: "【意見内容】",
  ocrText: "【OCRテキスト】",
};

export default function Highlight({ highlight }: Props) {
  return (
    <div className="space-y-3 text-sm leading-6 text-slate-700">
      {Object.entries(highlight)
        .slice(0, 3)
        .map(([field, fragments]) => (
          <div key={field} className="rounded-2xl bg-slate-50 px-4 py-3">
            <div className="mb-1 text-xs font-semibold tracking-wide text-slate-500">
              {fieldDisplayNames[field] || field}
            </div>
            <div
              className="[&_em]:rounded-sm [&_em]:bg-yellow-100 [&_em]:px-1 [&_em]:not-italic"
              dangerouslySetInnerHTML={{
                __html: (fragments.at(0) || "") + " … ",
              }}
            />
          </div>
        ))}
    </div>
  );
}
