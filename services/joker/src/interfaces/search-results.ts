// ドキュメントのソース型定義
export interface PatentDocumentSource {
    docId: string;
    kind: string;
    task: string;
    law: string;
    documentName: string;
    documentCode: string;
    fileReferenceId?: string;
    registrationNumber?: string;
    applicationNumber: string;
    internationalApplicationNumber?: string;
    appealReferenceNumber?: string;
    date: string;
    ocrText?: string;
    inventors?: string[];
    applicants?: string[];
    agents?: string[];
    assignees?: string[];
    tags?: string[];
    specialMentionMatterArticle?: string[];
    rejectionReasonArticle?: string[];
    lawOfIndustrialRegenerate?: string;
    inventionTitle?: string;
    technicalField?: string;
    backgroundArt?: string;
    techProblem?: string;
    techSolution?: string;
    advantageousEffects?: string;
    industrialApplicability?: string;
    referenceToDepositedBiologicalMaterial?: string;
    embodiments?: string;
    independentClaims?: string[];
    dependentClaims?: string[];
    abstract?: string;
    conclusionPartArticle?: string;
    draftingBody?: string;
    opinionContentsArticle?: string;
    contentsOfAmendment?: string[];
    extraNumbers?: string[];
}


export interface Hit {
    id: string;
    score: number | null;
    source: Partial<PatentDocumentSource>;
    highlight?: Record<string, string[]>;
}

export type SearchAggregationBucket = { key: string; doc_count: number };

export type SearchAggregations = {
    applicants: SearchAggregationBucket[];
    inventors: SearchAggregationBucket[];
    assignees: SearchAggregationBucket[];
    tags: SearchAggregationBucket[];
    documentNames: SearchAggregationBucket[];
    specialMentionMatterArticle: SearchAggregationBucket[];
    rejectionReasonArticle: SearchAggregationBucket[];
    priorityClaims: SearchAggregationBucket[];
};

export interface ApiResponseSuccess {
    page: number;
    size: number;
    total: number;
    hits: Hit[];
    aggregations: SearchAggregations;
};

export interface ApiResponseError {
    error?: string;
    message?: string;
};

export type ApiResponse = ApiResponseSuccess | ApiResponseError;
