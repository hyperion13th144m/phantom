export const getEnv = () => {
    const env = {
        ES_URL: process.env.ES_URL || "http://localhost:9200",
        ES_USER: process.env.ES_USER || "",
        ES_PASSWORD: process.env.ES_PASSWORD || "",
        ELASTICSEARCH_API_KEY: process.env.ELASTICSEARCH_API_KEY || "",
        IMAGE_BASE_URL: process.env.NEXT_PUBLIC_IMAGE_BASE_URL || process.env.IMAGE_BASE_URL || "",
        DOCUMENT_BASE_URL: process.env.NEXT_PUBLIC_DOCUMENT_BASE_URL || process.env.DOCUMENT_BASE_URL || "",
    };

    // デバッグ用ログ（開発時のみ）
    if (process.env.NODE_ENV !== "production") {
        console.log("[env.ts] Environment variables:", {
            ES_URL: env.ES_URL,
            ES_USER: env.ES_USER ? "***" : "(empty)",
            ES_PASSWORD: env.ES_PASSWORD ? "***" : "(empty)",
            ELASTICSEARCH_API_KEY: env.ELASTICSEARCH_API_KEY ? "***" : "(empty)",
            IMAGE_BASE_URL: env.IMAGE_BASE_URL,
            DOCUMENT_BASE_URL: env.DOCUMENT_BASE_URL,
        });
    }

    return env;
}