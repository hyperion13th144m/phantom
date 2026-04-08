import { defineMiddleware } from 'astro:middleware';
import logger from './lib/logger';

export const onRequest = defineMiddleware((context, next): Promise<Response> => {
    const request = context.request;
    const method = request.method;
    const url = new URL(request.url);
    const pathname = url.pathname;

    const startTime = Date.now();

    const responsePromise = next() as Promise<Response>;
    return responsePromise.then((response) => {
        const duration = Date.now() - startTime;
        const status = response.status;
        const userAgent = request.headers.get('user-agent') || '-';
        const referer = request.headers.get('referer') || '-';
        const forwardedFor = request.headers.get('x-forwarded-for');
        const clientIp = forwardedFor?.split(',')[0]?.trim()
            || request.headers.get('x-real-ip')
            || 'unknown';

        // アクセスログを記録（Apache Combined Log Format に準拠）
        logger.info({
            timestamp: new Date().toISOString(),
            clientIp,
            method,
            pathname,
            status,
            duration: `${duration}ms`,
            userAgent,
            referer,
            url: request.url,
        });

        return response;
    });
});
