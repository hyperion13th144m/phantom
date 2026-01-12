import type { NextConfig } from "next";

const imageBaseUrl = process.env.NEXT_PUBLIC_IMAGE_BASE_URL || "http://webserver:8080/content";
const url = new URL(imageBaseUrl);

const nextConfig: NextConfig = {
    /* config options here */
    allowedDevOrigins: [url.hostname],
    images: {
        remotePatterns: [
            {
                protocol: url.protocol.replace(":", "") as "http" | "https",
                hostname: url.hostname,
                port: url.port || "",
                pathname: `${url.pathname}/**`,
            },
        ]
    }
};

export default nextConfig;
