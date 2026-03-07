#!/bin/bash

SCRIPT_DIR="$(dirname $0)"
PROJECT_ROOT="$SCRIPT_DIR/.."
WORKSPACE_ROOT="$PROJECT_ROOT/.."

TEST_DATA_DIR="$WORKSPACE_ROOT/test-data"
TEMPLATE_CONFIG="$PROJECT_ROOT/storage-config-tmpl.json"
MONA_DIR="$WORKSPACE_ROOT/mona/src/mona/generated/config/"
FOX_DIR="$WORKSPACE_ROOT/fox/src/interfaces/generated/config"
JOKER_DIR="$WORKSPACE_ROOT/joker/generated/config"
CONFIG="storage-config.json"

MODE="prod"
if [ "$1" == "dev" ]; then
    MODE="dev"
fi

cd $PROJECT_ROOT || exit 1
uv run src/queen/build_dev_map.py \
  "$TEST_DATA_DIR" /tmp/"$CONFIG" "$TEMPLATE_CONFIG" --mode "$MODE"
if [ -f /tmp/"$CONFIG" ]
then
    mkdir -p "$MONA_DIR"
    mkdir -p "$FOX_DIR"
    mkdir -p "$JOKER_DIR"
    cp /tmp/"$CONFIG" "$MONA_DIR"
    cp /tmp/"$CONFIG" "$FOX_DIR"
    cp /tmp/"$CONFIG" "$JOKER_DIR"
    rm /tmp/"$CONFIG"
else
    echo "Error: Config file not found at $CONFIG"
    exit 1
fi