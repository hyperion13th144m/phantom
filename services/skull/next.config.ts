import type { NextConfig } from "next";

const isProd = true;// process.env.NODE_ENV === 'production';

const basePath = '/skull';

const nextConfig: NextConfig = {
    /* config options here */
    output: "standalone",
    reactStrictMode: true,
    basePath,
    assetPrefix: `${basePath}/`,
    trailingSlash: true, // 静的エクスポート時に推奨
    env: {
        NEXT_PUBLIC_BASE_PATH: basePath,
    },
};

export default nextConfig;
