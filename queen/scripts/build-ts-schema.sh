#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.." || exit 1

SRC=$1
DST=$2
SRC_FILE=$(basename "$SRC")
DST_FILE=$(basename "$DST")
SRC_DIR=$(dirname "$SRC")
DST_DIR=$(dirname "$DST")
OPT=${3:-}

if [ -z "$SRC" ] || [ -z "$DST" ]; then
    echo "Usage: $0 <source_json_file> <destination_ts_file>"
    exit 1
fi
if [ ! -f "$SRC" ]; then
    echo "Source file does not exist: $SRC"
    exit 1
fi
if [ ! -d "$DST_DIR" ]; then
    echo "Destination directory does not exist. Creating it."
    mkdir -p "$DST_DIR"
fi

docker run --rm -it \
  -v "$SRC_DIR":/src \
  -v "$DST_DIR":/dst \
  schema-builder-ts json2ts ${OPT} /src/"$SRC_FILE" /dst/"$DST_FILE" --cwd /src
