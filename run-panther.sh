#!/bin/sh

SCRIPT_DIR=$(dirname $0)
CMD="docker compose -f $SCRIPT_DIR/docker-compose.yml run --rm panther"
INDEX=patent-documents
MAPPING=elasticsearch/document-mapping.json

CREATE_INDEX_ARGS=" --index $INDEX --mapping $MAPPING"
UPLOAD_ARGS=" --index $INDEX --use-hash-guard --data-root /data_dir"

case $1 in
  "index")
    $CMD create-index $CREATE_INDEX_ARGS
    ;;
  "reindex")
    $CMD create-index $CREATE_INDEX_ARGS --recreate
    ;;
  "upload")
    $CMD upload $UPLOAD_ARGS
    ;;
  *)
    exit 1
    ;;
esac

