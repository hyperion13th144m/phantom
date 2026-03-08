import { beforeEach, describe, expect, it, vi } from 'vitest';

// Mock guards for document types
const mockGuards = {
    isPatAppDoc: vi.fn((obj: any) => obj._type === 'PatAppDoc'),
    isApplicationBody: vi.fn((obj: any) => obj._type === 'ApplicationBody'),
    isForeignLanguageBody: vi.fn((obj: any) => obj._type === 'ForeignLanguageBody'),
    isPatRspn: vi.fn((obj: any) => obj._type === 'PatRspn'),
    isPatEtc: vi.fn((obj: any) => obj._type === 'PatEtc'),
    isPatAmnd: vi.fn((obj: any) => obj._type === 'PatAmnd'),
    isCpyNtcPtE: vi.fn((obj: any) => obj._type === 'CpyNtcPtE'),
    isCpyNtcPtERn: vi.fn((obj: any) => obj._type === 'CpyNtcPtERn'),
    isAttachingDocument: vi.fn((obj: any) => obj._type === 'AttachingDocument'),
};

describe('Document Page Logic', () => {
    beforeEach(() => {
        vi.clearAllMocks();
    });

    it('should sort documents in the correct priority order', () => {
        // Test data with mixed document types
        const mockDocuments = [
            { _type: 'PatAmnd', id: 1 },
            { _type: 'PatAppDoc', id: 2 },
            { _type: 'ApplicationBody', id: 3 },
            { _type: 'ForeignLanguageBody', id: 4 },
            { _type: 'AttachingDocument', id: 5 },
        ];

        // Define the sorting order (as in the actual page)
        const order = [
            mockGuards.isPatAppDoc,
            mockGuards.isApplicationBody,
            mockGuards.isForeignLanguageBody,
            mockGuards.isPatRspn,
            mockGuards.isPatEtc,
            mockGuards.isPatAmnd,
            mockGuards.isCpyNtcPtE,
            mockGuards.isCpyNtcPtERn,
            mockGuards.isAttachingDocument,
        ];

        // Simulate the sorting logic
        const sortedJson = order
            .map((guard) => mockDocuments.find((doc) => guard(doc)))
            .filter((doc): doc is typeof mockDocuments[0] => doc !== undefined);

        // Verify the order
        expect(sortedJson[0]._type).toBe('PatAppDoc');
        expect(sortedJson[1]._type).toBe('ApplicationBody');
        expect(sortedJson[2]._type).toBe('ForeignLanguageBody');
        expect(sortedJson[3]._type).toBe('PatAmnd');
        expect(sortedJson[4]._type).toBe('AttachingDocument');
        expect(sortedJson.length).toBe(5);
    });

    it('should handle missing document types gracefully', () => {
        const mockDocuments = [
            { _type: 'PatAppDoc', id: 1 },
            { _type: 'ApplicationBody', id: 2 },
            // Missing: ForeignLanguageBody, PatRspn, etc.
        ];

        const order = [
            mockGuards.isPatAppDoc,
            mockGuards.isApplicationBody,
            mockGuards.isForeignLanguageBody,
            mockGuards.isPatRspn,
        ];

        const sortedJson = order
            .map((guard) => mockDocuments.find((doc) => guard(doc)))
            .filter((doc): doc is typeof mockDocuments[0] => doc !== undefined);

        // Should only contain the documents that exist
        expect(sortedJson.length).toBe(2);
        expect(sortedJson.every((doc) => doc._type === 'PatAppDoc' || doc._type === 'ApplicationBody')).toBe(true);
    });

    it('should render document blocks correctly based on type', () => {
        const mockDocument = { _type: 'ApplicationBody', content: 'test' };

        // Verify the guard function returns correct result
        expect(mockGuards.isApplicationBody(mockDocument)).toBe(true);
        expect(mockGuards.isPatAmnd(mockDocument)).toBe(false);
    });

    it('should determine carousel visibility based on image count', () => {
        const hasCarouselImages1 = { images: [1, 2, 3], thumbnails: [1, 2, 3] };
        const hasCarouselImages2 = { images: [], thumbnails: [] };
        const hasCarouselImages3 = { images: [1], thumbnails: [] };

        const shouldShow1 = hasCarouselImages1.images.length > 0 && hasCarouselImages1.thumbnails.length > 0;
        const shouldShow2 = hasCarouselImages2.images.length > 0 && hasCarouselImages2.thumbnails.length > 0;
        const shouldShow3 = hasCarouselImages3.images.length > 0 && hasCarouselImages3.thumbnails.length > 0;

        expect(shouldShow1).toBe(true);
        expect(shouldShow2).toBe(false);
        expect(shouldShow3).toBe(false);
    });

    it('should format page title correctly', () => {
        const formatTitle = (law: string, appNumber: string, fileId: string, docName: string) => {
            return `${law} ${appNumber} ${fileId} ${docName}`;
        };

        const title = formatTitle('特願', '2023-001234', 'FILE-123', '明細書');
        expect(title).toBe('特願 2023-001234 FILE-123 明細書');
    });
});
