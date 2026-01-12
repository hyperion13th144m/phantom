"use client";

interface Props {
    highlight: Record<string, string[]>;
}

const fieldDisplayNames: Record<string, string> = {
    inventionTitle: "【発明の名称】",
    independentClaims: "【独立請求項】",
    dependentClaims: "【従属請求項】",
    descriptionOfEmbodiments: "【実施形態】",
    abstract: "【要約】",
    applicants: "【出願人】",
    inventors: "【発明者】",
    assignee: "【譲受人】",
    tags: "【タグ】",
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
