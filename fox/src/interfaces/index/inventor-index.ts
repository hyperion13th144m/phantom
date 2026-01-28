export type InventorIndexEntry = {
    name: string;
    address: string;
    documents: {
        applicationNumberString: string;
        applicationNumberSlug: string;
        fileReferenceId: string | null;
    }[];
};
