import { getViteConfig } from 'astro/config';
import { resolve } from 'node:path';

export default getViteConfig({
    resolve: {
        alias: {
            '~': resolve(__dirname, './src'),
        },
    },
    test: {
        globals: true,
        environment: 'node',
        include: ['__tests__/**/*.test.ts'],
        coverage: {
            provider: 'v8',
            reporter: ['text', 'json', 'html'],
        },
    },
} as any);
