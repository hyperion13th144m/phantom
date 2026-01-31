import { defineMiddleware } from 'astro:middleware';
import { logger } from './lib/logger';

export const onRequest = defineMiddleware(async (context, next) => {
    const startTime = Date.now();

    try {
        const response = await next();
        const duration = Date.now() - startTime;

        // アクセスログを記録
        logger.access(context.request, response.status, duration);

        return response;
    } catch (error) {
        const duration = Date.now() - startTime;

        // エラーログを記録
        logger.error('Request failed', {
            method: context.request.method,
            url: context.request.url,
            duration,
            error: error instanceof Error ? error.message : String(error),
            stack: error instanceof Error ? error.stack : undefined,
        });

        throw error;
    }
});
