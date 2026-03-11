#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(dirname $0)"
PROJECT_ROOT="$SCRIPT_DIR/.."
cd "$PROJECT_ROOT" || exit 1

# ============================
# Paths and files.
# ============================
JSON_SCHEMA_DIR="$PROJECT_ROOT/out/json-schema"
PANTHER_SCHEMA="/panther-schema"
FOX_SCHEMA="/fox-schema"
BUILD_SCHEMA="$PROJECT_ROOT/scripts/build-schema.sh"
XSL_ROOT="$PROJECT_ROOT/src/queen/stylesheets/2.0"

# ============================
# Utility
# ============================
log() {
  echo ""
  echo "========================================"
  echo "$1"
  echo "========================================"
}

usage() {
  echo "Usage: $0 [ -j json_schema_dir ] [ -f fox_schema ] [ -p panther_schema ] [ -h ]"
  echo "This script builds the patent document schema by translating XML to JSON files and merging them."
}

while getopts "hj:f:p:" opt; do
  case $opt in
    h)
      usage
      exit 0
      ;;
    j)
      echo "Option -j with argument: $OPTARG"
      JSON_SCHEMA_DIR="$OPTARG"
      ;;
    f)
      echo "Option -f with argument: $OPTARG"
      FOX_SCHEMA="$OPTARG"
      ;;
    p)
      echo "Option -p with argument: $OPTARG"
      PANTHER_SCHEMA="$OPTARG"
      ;;
    *)
      echo "Invalid option: -$OPTARG" >&2
      usage
      exit 1
      ;;
  esac
done


# ============================
# Step 0: Prepare directories
# ============================
log "Preparing directories"

if [ ! -d "$JSON_SCHEMA_DIR" ]; then
  mkdir -p "$JSON_SCHEMA_DIR"
fi
if [ ! -d "$PANTHER_SCHEMA" ]; then
  mkdir -p "$PANTHER_SCHEMA"
fi
if [ ! -d "$FOX_SCHEMA" ]; then
  mkdir -p "$FOX_SCHEMA"
fi

# ============================
# Step 1: translate xsl as xml to json schemas.
# ============================
log "Step 1: translate xsl as xml to json schemas."
"$BUILD_SCHEMA" -o "$JSON_SCHEMA_DIR" -x "$XSL_ROOT"

# ============================
# Step 2: copy json schema to the projects
# ============================
log "Step 2: copy json schema to the projects"
cp -r "$JSON_SCHEMA_DIR/"* "$PANTHER_SCHEMA/"
cp -r "$JSON_SCHEMA_DIR/"* "$FOX_SCHEMA/"

# ============================
# Done
# ============================
log "All schema builds completed successfully!"