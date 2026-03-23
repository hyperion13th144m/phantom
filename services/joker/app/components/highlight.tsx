"use client";

interface Props {
    highlight: Record<string, string[]>;
}

const fieldDisplayNames: Record<string, string> = {
    independentClaims: "【独立請求項】",
    dependentClaims: "【従属請求項】",
    abstract: "【要約】",
    draftingBody: "【拒絶理由】",
    opinionContentsArticle: "【意見内容】",
    ocrText: "【OCRテキスト】",
};

const Highlight: React.FC<Props> = ({ highlight }) => {
    return (
        <div className="text-13/1.6">
            {Object.entries(highlight).slice(0, 3).map(([field, frags]) => (
                <div key={field} className="mb-2">
                    <span className="text-gray-600 font-semibold">{fieldDisplayNames[field] || field}</span>{" "}
                    <span
                        dangerouslySetInnerHTML={{
                            __html: (frags.at(0) || "") + " … ",
                        }}
                    />
                </div>
            ))}
        </div>
    );
}

export default Highlight;
