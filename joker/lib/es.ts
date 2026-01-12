import { Client } from "@elastic/elasticsearch";
import { getEnv } from "./env";

let esClient: Client | null = null;

export const getEsClient = () => {
    if (!esClient) {
        const { ES_URL, ELASTICSEARCH_API_KEY, ES_USER, ES_PASSWORD } = getEnv();
        const nodeUrl = ES_URL || "http://localhost:9200";

        esClient = new Client({
            node: nodeUrl,
            auth: ELASTICSEARCH_API_KEY
                ? { apiKey: ELASTICSEARCH_API_KEY }
                : ES_USER && ES_PASSWORD
                    ? { username: ES_USER, password: ES_PASSWORD }
                    : undefined,
        });
    }
    return esClient;
};

export const es = getEsClient();
