export interface IBibliographicData {
    inventors: string[];
    applicants: string[];
    agents: string[];
    documentName: string;
    documentCode: string;
    law: "patent" | "utilityModel";
    fileReferenceID: string;
    registrationNumber: string | null;
    applicationNumber: string;
    internationalApplicationNumber: string | null;
    appealReferenceNumber: string | null;
    submissionDate: string;
}
