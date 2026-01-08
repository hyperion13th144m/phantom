import type { TextBlocksRoot } from "./text-blocks-root";

// Intellectual Property Document Interface
export interface IPDocument {
    // Unique identifier for the document
    docId: string;

    // origin file name of the document
    archive: string;

    // origin procedure file name of the document
    procedure: string;

    // version of the document schema
    schemaVer: string;

    // task of the document extracted from the file name
    task: string;

    // kind of the document extracted from the file name
    kind: string;

    // extension of the origin file
    ext: string;

    // law type of the document
    law: "patent" | "utilityModel";

    // document name
    documentName: string;

    // document code
    documentCode: string;

    // file reference ID
    fileReferenceId: string;

    // registration number
    registrationNumber: string | null;

    // application number
    applicationNumber: string | null;

    // international application number
    internationalApplicationNumber: string | null;

    // appeal reference number
    appealReferenceNumber: string | null;

    // date of submission. Format: YYYYMMDD
    submissionDate: string;

    // time of submission. Format: HHMMSS
    submissionTime: string;

    // receipt number
    receiptNumber: string;

    // text blocks root of the document
    textBlocksRoot: TextBlocksRoot;

    // images associated with the document
    images: ImagesOfDocument[];

    // OCR text from the images.
    ocrText: string;
}

export interface ImagesOfDocument {
    number: string;
    filename: string;
    kind: "chemistry" | "figure" | "math" | "table" | "image" | "unknown";
    sizeTag: string;
    width: string;
    height: string;
    representative: string;
    description: string | null;
}
