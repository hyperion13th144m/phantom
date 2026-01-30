import { DocumentDate } from "~/lib/doc-date";
import { ApplicationNumber } from "~/lib/doc-number";
import type { Block } from "./document-block";

// document.json Interface
export interface DocumentJson {
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

    // submission date. Format: YYYYMMDD
    submissionDate: string | null;

    // submission time. Format: HHMMSS
    submissionTime: string | null;

    // dispatched date. Format: YYYYMMDD
    dispatchDate: string | null;

    // dispatched time. Format: HHMMSS
    dispatchTime: string | null;

    // receipt number
    receiptNumber: string;

    // text blocks root of the document
    blocks: Block[];

    // images associated with the document
    images: ImagesOfIPDocument[];

    // OCR text from the images.
    ocrText: string;

    // list of inventor names
    inventors?: string[];

    // list of applicant names
    applicants: string[];

    // list of patent agents
    agents?: string[];
}

export interface ImagesOfIPDocument {
    number: string;
    filename: string;
    kind: "chemistry" | "figure" | "math" | "table" | "image" | "unknown";
    sizeTag: string;
    width: number;
    height: number;
    representative: boolean;
    description: string | null;
}

export interface IPDocument extends Omit<DocumentJson, "submissionDate" | "applicationNumber" | "dispatchDate"> {
    submissionDate: DocumentDate | null;
    dispatchDate: DocumentDate | null;
    applicationNumber: ApplicationNumber;
};
