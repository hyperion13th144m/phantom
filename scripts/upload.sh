#!/bin/sh

SCRIPT_DIR=$(dirname $0)
PROJECT_DIR="$SCRIPT_DIR/.."
CMD="docker compose -f $PROJECT_DIR/docker-compose.yml run --rm -i panther"
INDEX=patent-documents

usage () {
  echo "Usage: $0 [ -s ]"
  echo "  -s: Skip existing documents if they already exist in the index."
  exit 1
}

while getopts "s" opt; do
  case $opt in
    s)
      SKIP_IF_EXISTS="--use-hash-guard"
      ;;
    *)
      usage
      ;;
  esac
done

$CMD upload-documents $SKIP_IF_EXISTS \
    --index $INDEX \
    --data-root /data_dir
