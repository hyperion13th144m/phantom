export type ApplicantIndexEntry = {
    name: string;
    address?: string;
    idNumber?: string;
    documents: {
        docId: string;
        applicationNumberString: string;
        applicationNumberSlug: string;
        fileReferenceId: string | null;
    }[];
};
