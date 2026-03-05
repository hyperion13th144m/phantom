#!/bin/bash

SCRIPT_DIR=$(dirname $0)
PROJECT_DIR="$SCRIPT_DIR/.."
cd $PROJECT_DIR || exit 1

# ES_USER, ES_PASSWORD, ES_INDEX is defined in .env file, which is used by both upload.sh and setup.sh.
# these variables are imported in docker-compose.yml,

# for development, define ES_URL in .env.

CMD="docker compose -f $PROJECT_DIR/docker-compose.yml run --rm -i panther"
INDEX=patent-documents

usage () {
  echo "Usage: $0 [ -s ] [ -p ] [ -d ]"
  echo "  -p: execute this script for production."
  echo "  -d: execute this script for debug."
  echo "  -s: Skip existing documents if they already exist in the index."
  exit 1
}

while getopts "spd" opt; do
  case $opt in
    s)
      SKIP_IF_EXISTS="--use-hash-guard"
      ;;
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
    upload-documents $SKIP_IF_EXISTS --data-root /data_dir
elif [ "$MODE" = "dev" ]; then
  source $PROJECT_DIR/.env
  export ES_URL ES_API_KEY ES_USER ES_PASSWORD ES_INDEX
  uv run $PROJECT_DIR/panther/src/panther/main.py \
    upload-documents $SKIP_IF_EXISTS --data-root $DATA_DIR
else
  usage
fi

