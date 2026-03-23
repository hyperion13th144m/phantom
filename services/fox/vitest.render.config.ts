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
        include: ['__tests__/fixtures/render-*.test.ts'],
    },
} as any);
