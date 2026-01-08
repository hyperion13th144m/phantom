import { Client } from "@elastic/elasticsearch";

export const es = new Client({
    node: process.env.ES_URL!,
    auth: process.env.ELASTICSEARCH_API_KEY
        ? { apiKey: process.env.ELASTICSEARCH_API_KEY }
        : process.env.ES_USER && process.env.ES_PASSWORD
            ? { username: process.env.ES_USER, password: process.env.ES_PASSWORD }
            : undefined,
});
