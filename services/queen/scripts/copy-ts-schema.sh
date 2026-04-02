#!/bin/bash

SCRIPT_DIR="$(dirname $0)"
PROJECT_ROOT="$(dirname $SCRIPT_DIR)"

# ============================
# Paths and files.
# ============================
SRC_DIR="$PROJECT_ROOT/generated/typescript"
DST_DIR=(
    "/fox-models"
    "/joker-models"
)

for dst in "${DST_DIR[@]}"; do
    if [ ! -d "$dst" ]; then
        echo "ERROR: Destination directory $dst does not exist."
        exit 1
    fi

    cp "$SRC_DIR"/*.ts "$dst"/
done
