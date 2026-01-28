export type ApplicantIndexEntry = {
    name: string;
    address?: string;
    idNumber?: string;
    documents: {
        applicationNumberString: string;
        applicationNumberSlug: string;
        fileReferenceId: string | null;
    }[];
};
