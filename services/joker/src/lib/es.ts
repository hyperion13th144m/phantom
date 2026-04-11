import type { Client } from "@elastic/elasticsearch";
import { getEnv } from "./env";

let esClientPromise: Promise<Client> | null = null;

export const ES_INDEX = process.env.ES_INDEX ?? "patent-documents";

export async function getEsClient(): Promise<Client> {
  if (esClientPromise) {
    return esClientPromise;
  }

  esClientPromise = (async () => {
    const { Client: ElasticsearchClient } = await import(
      "@elastic/elasticsearch"
    );
    const { ES_URL, ELASTICSEARCH_API_KEY, ES_USER, ES_PASSWORD } = getEnv();
    const nodeUrl = ES_URL || "http://localhost:9200";

    return new ElasticsearchClient({
      node: nodeUrl,
      auth: ELASTICSEARCH_API_KEY
        ? { apiKey: ELASTICSEARCH_API_KEY }
        : ES_USER && ES_PASSWORD
          ? { username: ES_USER, password: ES_PASSWORD }
          : undefined,
    });
  })();

  return esClientPromise;
}
