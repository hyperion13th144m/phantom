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
    images?: {
        filename: string;
        width: number;
        height: number;
        number: string;
        kind: string;
        representative: boolean;
        description: string;
        sizeTag: string;
    }[];
    extraNumbers?: string[];
}
export interface ImageInformation {
    number: string;
    filename: string;
    kind: string;
    sizeTag: string;
    width: number;
    height: number;
    description: string;
    representative: boolean;
}

export interface Hit {
    id: string;
    score: number | null;
    source: Partial<PatentDocumentSource>;
    highlight?: Record<string, string[]>;
}

export interface ApiResponseSuccess {
    page: number;
    size: number;
    total: number;
    hits: Hit[];
    aggregations: {
        applicants: { key: string; doc_count: number }[];
        inventors: { key: string; doc_count: number }[];
        assignees: { key: string; doc_count: number }[];
        tags: { key: string; doc_count: number }[];
        documentNames: { key: string; doc_count: number }[];
        specialMentionMatterArticle: { key: string; doc_count: number }[];
        rejectionReasonArticle: { key: string; doc_count: number }[];
        priorityClaims: { key: string; doc_count: number }[];
    }
};

export interface ApiResponseError {
    error?: string;
    message?: string;
};

export type ApiResponse = ApiResponseSuccess | ApiResponseError;
