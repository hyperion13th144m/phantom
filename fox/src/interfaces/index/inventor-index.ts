export type InventorIndexEntry = {
    name: string;
    address: string;
    documents: {
        docId: string;
        applicationNumberString: string;
        applicationNumberSlug: string;
        fileReferenceId: string | null;
    }[];
};
