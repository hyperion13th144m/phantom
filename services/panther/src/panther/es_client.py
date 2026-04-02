from typing import Optional

from elasticsearch import Elasticsearch


def create_es_client(
    api_key: Optional[str] = None,
    user: Optional[str] = None,
    password: Optional[str] = None,
    es_url: str = "http://localhost:9200",
) -> Elasticsearch:
    """Create Elasticsearch client from common arguments."""
    if api_key:
        return Elasticsearch(es_url, api_key=api_key)
    elif user and password:
        return Elasticsearch(es_url, basic_auth=(user, password))
    else:
        return Elasticsearch(es_url)
