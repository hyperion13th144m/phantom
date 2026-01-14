import type { NextConfig } from "next";

const isProd = process.env.NODE_ENV === "production";

const nextConfig: NextConfig = {
    /* config options here */
    output: "standalone",
    reactStrictMode: true,
    basePath: isProd ? "/phantom" : "",
};

export default nextConfig;
