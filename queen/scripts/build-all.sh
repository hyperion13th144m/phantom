#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(dirname $0)"
PROJECT_ROOT="$SCRIPT_DIR/.."

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

TARGET="ALL"
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
      TARGET="fox"
      ;;
    p)
      echo "Option -p with argument: $OPTARG"
      PANTHER_SCHEMA="$OPTARG"
      TARGET="panther"
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


# ============================
# Step 1: translate xsl as xml to json schemas.
# ============================
log "Step 1: translate xsl as xml to json schemas."
"$BUILD_SCHEMA" -o "$JSON_SCHEMA_DIR" -x "$XSL_ROOT"

# ============================
# Step 2: copy json schema to the projects
# ============================
log "Step 2: copy json schema to the projects"
if [ $TARGET = "panther" ]; then
  if [ ! -d "$PANTHER_SCHEMA" ]; then
    mkdir -p "$PANTHER_SCHEMA"
  fi
  cp "$JSON_SCHEMA_DIR/"* "$PANTHER_SCHEMA/"
fi

if [ $TARGET = "fox" ]; then
  if [ ! -d "$FOX_SCHEMA" ]; then
    mkdir -p "$FOX_SCHEMA"
  fi
  cp "$JSON_SCHEMA_DIR/"* "$FOX_SCHEMA/"
fi

if [ $TARGET = "ALL" ]; then
  if [ ! -d "$PANTHER_SCHEMA" ]; then
    mkdir -p "$PANTHER_SCHEMA"
  fi
  cp "$JSON_SCHEMA_DIR/"* "$PANTHER_SCHEMA/"

  if [ ! -d "$FOX_SCHEMA" ]; then
    mkdir -p "$FOX_SCHEMA"
  fi
  cp "$JSON_SCHEMA_DIR/"* "$FOX_SCHEMA/"
fi


# ============================
# Done
# ============================
log "All schema builds completed successfully!"