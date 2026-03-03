#!/bin/sh

SCRIPT_DIR=$(dirname $0)
PROJECT_DIR="$SCRIPT_DIR/.."
CMD="docker compose -f $PROJECT_DIR/docker-compose.yml run --rm -i panther"
INDEX=patent-documents
MAPPING=elasticsearch/document-mapping.json

CREATE_INDEX_ARGS=" --index $INDEX --mapping $MAPPING"
UPLOAD_ARGS=" --index $INDEX --use-hash-guard --data-root /data_dir"

usage () {
  echo "Usage: $0 {import|upload}"
  echo "  import: Import extra data from the SQLite database to the Elasticsearch."
  echo "  upload: Upload extra data to the Elasticsearch index. This should be run after 'crawl.sh'."
  exit 1
}

case $1 in
  "import")
    $CMD import-extra-data \
    --sqlite-db /extra_dir/extra_data.sqlite3 \
    --data-root /data_dir
    ;;
  "upload")
    $CMD upload-extra-data \
    --sqlite-db /extra_dir/extra_data.sqlite3 \
    --index patent-documents
   ;;
  *)
    usage
    ;;
esac

