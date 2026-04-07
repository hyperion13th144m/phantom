#!/bin/bash

SCRIPT_DIR=$(dirname "$0")
PROJECT_ROOT=$(dirname "$SCRIPT_DIR")

INDEX=patent-documents
ES_HOST=localhost
ES_PORT=9200
MODE=production

while getopts m:e:p:i: OPT
do
  case $OPT in
  m) MODE=$OPTARG
     ;;
  e) ES_HOST=$OPTARG
     ;;
  p) ES_PORT=$OPTARG
     ;;
  i) INDEX=$OPTARG
     ;;
  *) exit 1
     ;;
  esac
done

shift $((OPTIND - 1)) # オプション部分をスキップ

MAPPING_FILE=${1:-$SCRIPT_DIR/mapping.json}

if [ $MODE = "production" ]; then
  CONFIG=docker-compose.yml
  CONTAINER=es:main
else
  CONFIG=docker-compose.dev.yml
  CONTAINER=es-dev
fi

docker compose -f $PROJECT_ROOT/$CONFIG exec $CONTAINER \
  curl -X DELETE "http://$ES_HOST:$ES_PORT/$INDEX"
docker compose -f $PROJECT_ROOT/$CONFIG cp $MAPPING_FILE $CONTAINER:/tmp/mapping.json
docker compose -f $PROJECT_ROOT/$CONFIG exec $CONTAINER \
  curl -X PUT "http://$ES_HOST:$ES_PORT/$INDEX" -H 'Content-Type: application/json' -d @/tmp/mapping.json
