// API route to serve images for a document in development environment.
// In production, images are served directly by the reverse proxy from the MONA server,
// so this API route is not used.

import type { APIRoute } from 'astro';

const MONA_URL = process.env.MONA_URL ?? "http://mona-dev:8000";

export const GET: APIRoute = async ({ params }) => {
    const docId = params.docId;
    const filename = params.filename;
    if (!docId) {
        return new Response(JSON.stringify({ error: 'docId is required' }), { status: 400 });
    }

    if (!filename) {
        return new Response(JSON.stringify({ error: 'filename is required' }), { status: 400 });
    }

    try {
        const res = await fetch(`${MONA_URL}/documents/${docId}/images/${filename}`);
        if (!res.ok) {
            return new Response(JSON.stringify({ error: 'API fetch failed' }), { status: 500 });
        }
        const data = await res.arrayBuffer();
        const contentType = res.headers.get('Content-Type') || 'application/octet-stream';
        return new Response(data, {
            status: 200,
            headers: { 'Content-Type': contentType }
        });
    } catch {
        return new Response(JSON.stringify({ error: 'Server error' }), { status: 500 });
    }
};
