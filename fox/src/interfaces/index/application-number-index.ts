export type ApplicationNumberIndexEntry = {
    yearPart: string;
    applicationNumberString: string;
    documents: {
        docId: string;
        documentName: string;
        // 整理番号は通常は出願番号に一対一で紐付くが、運用によっては手続ごとに変えることがあるかも。
        fileReferenceId?: string | null;
        submissionDate: string | null;
        dispatchDate: string | null;
    }[];
};
