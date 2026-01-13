from elasticsearch import Elasticsearch


def create_es_client(args) -> Elasticsearch:
    """Create Elasticsearch client from common arguments."""
    if args.api_key:
        return Elasticsearch(args.es, api_key=args.api_key)
    elif args.user and args.password:
        return Elasticsearch(args.es, basic_auth=(args.user, args.password))
    else:
        return Elasticsearch(args.es)

