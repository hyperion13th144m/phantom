export interface DocListDocument {
  docId: string;
  applicants: string[];
  fileReferenceId: string;
  date: string;
  documentName: string;
  documentCode: string;
  extraNumbers?: string[];
}

export interface DocListGroup {
  law: string;
  applicationNumber: string;
  docs: DocListDocument[];
}

export interface DocListSource {
  docId?: string;
  law?: string;
  applicationNumber?: string;
  applicants?: string[] | string;
  fileReferenceId?: string;
  date?: string;
  documentName?: string;
  documentCode?: string;
  extraNumbers?: string[] | string;
}

export interface DocListApiError {
  error: string;
  message: string;
}

export type DocListApiResponse = DocListGroup[];
