#!/bin/bash

SCRIPT_DIR="$(dirname $0)"
PROJECT_ROOT="$(dirname $SCRIPT_DIR)"

# ============================
# Paths and files.
# ============================
SRC_DIR="$PROJECT_ROOT/generated/python"
DST_DIR=(
    "/panther-models"
)

# ============================
# Copy generated Python schema files to destination directories.
# ============================
for dst in "${DST_DIR[@]}"; do
    if [ ! -d "$dst" ]; then
        echo "ERROR: Destination directory $dst does not exist."
        exit 1
    fi

    cp "$SRC_DIR"/*.py "$dst"/
done


# ============================
# Generate mapping file for elasticsearch and copy to destination directories.
# ============================
SCHEMA="$PROJECT_ROOT/generated/json-schema/full-text.json"
CONFIG="$PROJECT_ROOT/scripts/mapping-config.json"
OUTPUT="/panther-models/document-mapping.json"
uv run python $PROJECT_ROOT/scripts/generate_mapping.py \
   --schema "$SCHEMA" --config "$CONFIG" --output "$OUTPUT"