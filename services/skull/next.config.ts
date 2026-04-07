import type { NextConfig } from "next";

const isProd = true;// process.env.NODE_ENV === 'production';

const nextConfig: NextConfig = {
    /* config options here */
    output: "standalone",
    reactStrictMode: true,
    basePath: '/skull',
    assetPrefix: '/skull/',
    trailingSlash: true, // 静的エクスポート時に推奨
};

export default nextConfig;
