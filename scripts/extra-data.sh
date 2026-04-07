#!/bin/bash

SCRIPT_DIR=$(dirname "$0")
_PROJECT_ROOT=$(dirname "$SCRIPT_DIR")
PROJECT_ROOT=$(readlink -f "$_PROJECT_ROOT")

MODE=production

while getopts m: OPT
do
  case $OPT in
  m) MODE=$OPTARG
     ;;
  *) exit 1
     ;;
  esac
done

shift $((OPTIND - 1)) # オプション部分をスキップ


if [ $MODE = "production" ]; then
  CONFIG=docker-compose.yml
  CONTAINER=skull:main
else
  CONFIG=docker-compose.dev.yml
  CONTAINER=skull-dev
fi

docker compose -f $PROJECT_ROOT/$CONFIG run --rm $CONTAINER npx tsx init-db.ts
