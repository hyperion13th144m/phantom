#!/bin/sh

SCRIPT_DIR=$(dirname $0)
docker compose -f $SCRIPT_DIR/docker-compose.yml run --rm mona -m 2 /src_dir /data_dir A163

