import type { APIRoute } from 'astro';

const MONA_URL = import.meta.env.MONA_URL;

export const GET: APIRoute = async ({ params }) => {
    const docId = params.docId;
    const dataType = params.dataType;
    console.log(`Received request for docId: ${docId}, dataType: ${dataType}`);
    if (!docId) {
        return new Response(JSON.stringify({ error: 'docId is required' }), { status: 400 });
    }

    if (!dataType ||
        (dataType !== 'content' && dataType !== 'bibliographic-items' &&
            dataType !== 'images-information')) {
        return new Response(JSON.stringify({ error: 'Invalid dataType' }), { status: 400 });
    }

    try {
        const res = await fetch(`${MONA_URL}/documents/${docId}/json/${dataType}`);
        if (!res.ok) {
            return new Response(JSON.stringify({ error: 'API fetch failed' }), { status: 500 });
        }
        const data = await res.json();
        return new Response(JSON.stringify(data), {
            status: 200,
            headers: { 'Content-Type': 'application/json' }
        });
    } catch {
        return new Response(JSON.stringify({ error: 'Server error' }), { status: 500 });
    }
};
