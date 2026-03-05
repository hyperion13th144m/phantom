#!/bin/bash

SCRIPT_DIR=$(dirname $0)
PROJECT_DIR="$SCRIPT_DIR/.."
cd $PROJECT_DIR || exit 1

# ES_USER, ES_PASSWORD, ES_INDEX is defined in .env file, which is used by both upload.sh and setup.sh.
# these variables are imported in docker-compose.yml,

# for development, define ES_URL in .env.

usage () {
  echo "Usage: $0 [ -p ] [ -d ]"
  echo "  -p: execute this script for production."
  echo "  -d: execute this script for debug."
  echo "  restore extra data from the SQLite database to the Elasticsearch."
  echo "  RECOMMENDED: this script should be executed after upload.sh for uploading json data to Elasticsearch."
  exit 1
}

while getopts "pd" opt; do
  case $opt in
    p)
      MODE=prod
      ;;
    d)
      MODE=dev
      ;;
    *)
      usage
      ;;
  esac
done

if [ "$MODE" = "prod" ]; then
  docker compose -f $PROJECT_DIR/docker-compose.yml run --rm -i panther \
    restore-metadata --sqlite-db /extra_dir/extra_data.sqlite3
elif [ "$MODE" = "dev" ]; then
  source $PROJECT_DIR/.env
  export ES_URL ES_API_KEY ES_USER ES_PASSWORD ES_INDEX
  uv run $PROJECT_DIR/panther/src/panther/main.py \
    restore-metadata --sqlite $EXTRA_DATA_DIR/extra_data.sqlite3 
else
  usage
fi
