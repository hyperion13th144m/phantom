export const getEnv = () => {
    return {
        ES_URL: process.env.ES_URL || "http://localhost:9200",
        ES_USER: process.env.ES_USER || "",
        ES_PASSWORD: process.env.ES_PASSWORD || "",
        ELASTICSEARCH_API_KEY: process.env.ELASTICSEARCH_API_KEY || "",
        IMAGE_BASE_URL: process.env.IMAGE_BASE_URL || "",
        DOCUMENT_BASE_URL: process.env.DOCUMENT_BASE_URL || "",
    }
}