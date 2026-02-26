// @ts-check
import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';

/* public/images は dist(/wwwroot) にコピーしない。
   pulibc/images は nginx で直接配信するため、Vite の publicDir から除外する。
   public/images は 開発時の確認のため。
*/
// https://astro.build/config
export default defineConfig({
    outDir: "/wwwroot",
    vite: {
        plugins: [tailwindcss()],
        resolve: {
            alias: {
                '~': '/src',
            }
        },
        publicDir: process.env.NODE_ENV === "production" ? false : "public",
    },
});
