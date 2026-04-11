import type { APIRoute } from 'astro';
import {
    DocumentMetadataNotFoundError,
    ElasticsearchRequestError,
    MissingEsConfigError,
    fetchDocumentMetadata,
} from '~/lib/es-document-metadata';

export const GET: APIRoute = async ({ params }) => {
    const docId = params.docId;

    if (!docId) {
        return new Response(JSON.stringify({ error: 'docId is required' }), { status: 400 });
    }

    try {
        const metadata = await fetchDocumentMetadata(docId);
        return new Response(JSON.stringify(metadata), {
            status: 200,
            headers: { 'Content-Type': 'application/json' },
        });
    } catch (error) {
        if (error instanceof MissingEsConfigError) {
            return new Response(JSON.stringify({ error: error.message }), { status: 500 });
        }

        if (error instanceof DocumentMetadataNotFoundError) {
            return new Response(JSON.stringify({ error: error.message }), { status: 404 });
        }

        if (error instanceof ElasticsearchRequestError) {
            return new Response(JSON.stringify({ error: error.message }), { status: 502 });
        }

        return new Response(JSON.stringify({ error: 'Server error' }), { status: 500 });
    }
};
