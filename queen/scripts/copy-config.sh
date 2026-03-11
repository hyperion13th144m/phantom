#!/bin/bash

SCRIPT_DIR="$(dirname $0)"
PROJECT_ROOT="$SCRIPT_DIR/.."

MONA_DIR="/mona-config"
FOX_DIR="/fox-config"
JOKER_DIR="/joker-config"
CONFIG="$PROJECT_ROOT/storage-config.json"

cd $PROJECT_ROOT || exit 1

cp "$CONFIG" "$MONA_DIR"
cp "$CONFIG" "$FOX_DIR"
cp "$CONFIG" "$JOKER_DIR"
