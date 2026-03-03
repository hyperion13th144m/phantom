#!/bin/sh

SCRIPT_DIR=$(dirname $0)
PROJECT_DIR="$SCRIPT_DIR/.."
cd $PROJECT_DIR || exit 1
CMD="docker compose -f docker-compose.yml run --rm -i panther"
INDEX=patent-documents
MAPPING=elasticsearch/document-mapping.json

CREATE_INDEX_ARGS="create-index --index $INDEX --mapping $MAPPING --recreate"
UPLOAD_ARGS=" --index $INDEX --use-hash-guard --data-root /data_dir"

usage () {
  echo "Usage: $0 {init|reindex|upload}"
  echo "  init: Create the Elasticsearch index if it does not exist."
  echo "  reindex: Recreate the Elasticsearch index. WARNING: This will delete all existing data in the index."
  echo "  upload: Upload documents to the Elasticsearch index. This should be run after 'init' or 'reindex'."
  exit 1
}

echo "Recreating the Elasticsearch index. WARNING: This will delete all existing data in the index."
$CMD $CREATE_INDEX_ARGS
if [ $? -ne 0 ]; then
  echo "Failed to recreate the Elasticsearch index."
  exit 1
else
  echo "Elasticsearch index recreated successfully."
fi

source $PROJECT_DIR/.env
if [ -z "$EXTRA_DATA_DIR" ]; then
  echo "EXTRA_DATA_DIR is not set in the .env file. skipped"
else
  EXTRA_DATA="$EXTRA_DATA_DIR/extra_data.sqlite3"
fi

if [ -f "$EXTRA_DATA" ]; then
  echo "Extra data file is already exists. Skipping initialization of extra data."
  exit 1
else
  echo "Initializing extra data..."
  $CMD create-db --sqlite-db /extra_dir/extra_data.sqlite3
  if [ $? -ne 0 ]; then
    echo "Failed to initialize extra data."
    exit 1
  else
    echo "Extra data initialized successfully."
  fi
fi
