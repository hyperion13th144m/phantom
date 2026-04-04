import { Client } from "@elastic/elasticsearch";

const node = process.env.ES_URL;
if (!node) {
    throw new Error("ES_URL is not set");
}

export const esClient = new Client({
    node,
    auth:
        process.env.ES_USER && process.env.ES_PASSWORD
            ? {
                username: process.env.ES_USER,
                password: process.env.ES_PASSWORD,
            }
            : undefined,
});

export const ES_INDEX = process.env.ES_INDEX ?? "patent-documents";