import {
    DocumentMetadataNotFoundError,
    ElasticsearchRequestError,
    MissingEsConfigError,
    fetchDocumentMetadata,
    getEsConfigFromEnv,
    normalizeDocumentMetadata,
} from '~/lib/es-document-metadata';

describe('es-document-metadata', () => {
    const env = {
        ES_URL: 'http://localhost:9200',
        ES_USER: 'elastic',
        ES_PASSWORD: 'secret',
        ES_INDEX: 'documents',
    };

    afterEach(() => {
        vi.restoreAllMocks();
    });

    it('reads Elasticsearch config from env', () => {
        expect(getEsConfigFromEnv(env as NodeJS.ProcessEnv)).toEqual({
            url: 'http://localhost:9200',
            user: 'elastic',
            password: 'secret',
            index: 'documents',
        });
    });

    it('throws when Elasticsearch config is missing', () => {
        expect(() => getEsConfigFromEnv({ ...env, ES_PASSWORD: '' } as NodeJS.ProcessEnv)).toThrow(MissingEsConfigError);
    });

    it('normalizes missing metadata fields', () => {
        expect(normalizeDocumentMetadata({ memo: 123 as any, tags: ['a', 1 as any] as any })).toEqual({
            extraNumbers: [],
            assignees: [],
            tags: ['a'],
            memo: null,
        });
    });

    it('fetches metadata by docId', async () => {
        const fetchMock = vi.spyOn(globalThis, 'fetch').mockResolvedValue({
            ok: true,
            json: async () => ({
                hits: {
                    hits: [
                        {
                            _source: {
                                extraNumbers: ['EX-1'],
                                assignees: ['alice'],
                                tags: ['urgent'],
                                memo: 'hello',
                            },
                        },
                    ],
                },
            }),
        } as Response);

        await expect(fetchDocumentMetadata('doc-123', env as NodeJS.ProcessEnv)).resolves.toEqual({
            extraNumbers: ['EX-1'],
            assignees: ['alice'],
            tags: ['urgent'],
            memo: 'hello',
        });

        expect(fetchMock).toHaveBeenCalledWith(
            new URL('/documents/_search', 'http://localhost:9200/'),
            expect.objectContaining({
                method: 'POST',
                headers: expect.objectContaining({
                    Authorization: expect.stringMatching(/^Basic /),
                    'Content-Type': 'application/json',
                }),
            }),
        );
    });

    it('throws not found when no hit exists', async () => {
        vi.spyOn(globalThis, 'fetch').mockResolvedValue({
            ok: true,
            json: async () => ({
                hits: {
                    hits: [],
                },
            }),
        } as Response);

        await expect(fetchDocumentMetadata('doc-404', env as NodeJS.ProcessEnv)).rejects.toThrow(DocumentMetadataNotFoundError);
    });

    it('throws request error when Elasticsearch returns non-ok', async () => {
        vi.spyOn(globalThis, 'fetch').mockResolvedValue({
            ok: false,
            status: 503,
        } as Response);

        await expect(fetchDocumentMetadata('doc-503', env as NodeJS.ProcessEnv)).rejects.toThrow(ElasticsearchRequestError);
    });
});
