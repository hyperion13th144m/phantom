#!/bin/bash

SCRIPT_DIR=$(dirname $0)
PROJECT_DIR="$SCRIPT_DIR/.."
cd $PROJECT_DIR || exit 1

# ES_USER, ES_PASSWORD, ES_INDEX is defined in .env file, which is used by both upload.sh and setup.sh.
# these variables are imported in docker-compose.yml,

# for development, define ES_URL in .env.

CMD="docker compose -f docker-compose.yml run --rm -i panther"
ARGS="create-index --recreate"

usage () {
  echo "Usage: $0 [ -p ] [ -d ]"
  echo "  -p: execute this script for production."
  echo "  -d: execute this script for debug."
  echo "  create the Elasticsearch index. WARNING: This will delete all existing data in the index."
  exit 1
}

while getopts "pd" opt; do
  case $opt in
    p)
      MODE=prod
      MAPPING="--mapping elasticsearch/document-mapping.json"
      ;;
    d)
      MODE=dev
      MAPPING="--mapping $PROJECT_DIR/panther/elasticsearch/document-mapping.json"
      ;;
    *)
      usage
      ;;
  esac
done

if [ "$MODE" = "prod" ]; then
  docker compose -f $PROJECT_DIR/docker-compose.yml run --rm -i panther $ARGS $MAPPING
elif [ "$MODE" = "dev" ]; then
  source $PROJECT_DIR/.env
  export ES_URL ES_API_KEY ES_USER ES_PASSWORD ES_INDEX
  uv run $PROJECT_DIR/panther/src/panther/main.py $ARGS $MAPPING
else
  usage
fi
