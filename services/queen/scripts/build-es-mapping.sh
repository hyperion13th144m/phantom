#!/bin/bash

SCRIPT_DIR="$(dirname $0)"
PROJECT_ROOT="$(dirname $SCRIPT_DIR)"

# ============================
# Generate mapping file for elasticsearch and copy to destination directories.
# ============================
SCHEMA="$PROJECT_ROOT/generated/json-schema/full-text.json"
CONFIG="$PROJECT_ROOT/scripts/mapping-config.json"
OUTPUT="/es-mapping/mapping.json"
uv run python $PROJECT_ROOT/scripts/generate_mapping.py \
   --schema "$SCHEMA" --config "$CONFIG" --output "$OUTPUT"