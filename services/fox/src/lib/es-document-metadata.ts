export type DocumentMetadata = {
    extraNumbers: string[];
    assignees: string[];
    tags: string[];
    memo: string | null;
};

type ElasticsearchHit = {
    _source?: Partial<DocumentMetadata>;
};

type ElasticsearchSearchResponse = {
    hits?: {
        hits?: ElasticsearchHit[];
    };
};

type EsConfig = {
    url: string;
    user: string;
    password: string;
    index: string;
};

export class MissingEsConfigError extends Error {
    constructor() {
        super('Elasticsearch configuration is incomplete');
        this.name = 'MissingEsConfigError';
    }
}

export class DocumentMetadataNotFoundError extends Error {
    constructor(docId: string) {
        super(`Document metadata not found for docId: ${docId}`);
        this.name = 'DocumentMetadataNotFoundError';
    }
}

export class ElasticsearchRequestError extends Error {
    constructor(message: string) {
        super(message);
        this.name = 'ElasticsearchRequestError';
    }
}

export const getEsConfigFromEnv = (
    env: NodeJS.ProcessEnv = process.env,
): EsConfig => {
    const url = env.ES_URL?.trim();
    const user = env.ES_USER?.trim();
    const password = env.ES_PASSWORD?.trim();
    const index = env.ES_INDEX?.trim();

    if (!url || !user || !password || !index) {
        throw new MissingEsConfigError();
    }

    return { url, user, password, index };
};

export const normalizeDocumentMetadata = (
    source: Partial<DocumentMetadata> | undefined,
): DocumentMetadata => ({
    extraNumbers: Array.isArray(source?.extraNumbers)
        ? source.extraNumbers.filter((value): value is string => typeof value === 'string')
        : [],
    assignees: Array.isArray(source?.assignees)
        ? source.assignees.filter((value): value is string => typeof value === 'string')
        : [],
    tags: Array.isArray(source?.tags)
        ? source.tags.filter((value): value is string => typeof value === 'string')
        : [],
    memo: typeof source?.memo === 'string' ? source.memo : null,
});

export const fetchDocumentMetadata = async (
    docId: string,
    env: NodeJS.ProcessEnv = process.env,
): Promise<DocumentMetadata> => {
    const config = getEsConfigFromEnv(env);
    const endpoint = new URL(`/${config.index}/_search`, config.url.endsWith('/') ? config.url : `${config.url}/`);
    const auth = Buffer.from(`${config.user}:${config.password}`).toString('base64');

    const response = await fetch(endpoint, {
        method: 'POST',
        headers: {
            Authorization: `Basic ${auth}`,
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            size: 1,
            _source: ['extraNumbers', 'assignees', 'tags', 'memo'],
            query: {
                term: {
                    docId,
                },
            },
        }),
    });

    if (!response.ok) {
        throw new ElasticsearchRequestError(`Elasticsearch request failed with status ${response.status}`);
    }

    const data = await response.json() as ElasticsearchSearchResponse;
    const hit = data.hits?.hits?.[0];

    if (!hit?._source) {
        throw new DocumentMetadataNotFoundError(docId);
    }

    return normalizeDocumentMetadata(hit._source);
};

export const getDocumentMetadata = async (docId: string, origin: string) => {
    try {
        const res = await fetch(`${origin}/api/${docId}/metadata`);
        if (!res.ok) throw new Error(`API Error: ${res.status}`);
        return await res.json() as DocumentMetadata;
    } catch (err) {
        console.error(err);
        return null;
    }
};
