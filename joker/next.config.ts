import type { NextConfig } from "next";

const nextConfig: NextConfig = {
    /* config options here */
    output: "standalone",
    reactStrictMode: true,
    images: {
        remotePatterns: [
            {
                protocol: "http",
                hostname: "nginx",
                port: "8080",
                pathname: "/static/content/**",
            },
        ]
    },
    // development環境ではリバースプロキシ設定
    async rewrites() {
        return [
            {
                source: "/content/:path*",
                destination: "http://nginx-dev:38080/content/:path*",
            },
        ];
    },
};

export default nextConfig;
