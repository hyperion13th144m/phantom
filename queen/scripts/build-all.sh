#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/.."
WORKSPACE_ROOT="$PROJECT_ROOT/.."

cd "$PROJECT_ROOT" || exit 1

WORK_DIR="$PROJECT_ROOT/out"
OUTPUT_DIR="$WORK_DIR/schema"

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
  echo "Usage: $0 [ -o output_dir ] [ -w work_dir ] [ -d ]"
  echo "This script builds the patent document schema by translating XML to JSON files and merging them."
}

while getopts "hdw:o:" opt; do
  case $opt in
    h)
      usage
      exit 0
      ;;
    o)
      echo "Option -o with argument: $OPTARG"
      OUTPUT_DIR="$OPTARG"
      ;;
    w)
      echo "Option -w with argument: $OPTARG"
      WORK_DIR="$OPTARG"
      ;;
    d)
      echo "Option -d (debug mode) enabled"
      DEBUG="--debug"
      ;;
    *)
      echo "Invalid option: -$OPTARG" >&2
      usage
      exit 1
      ;;
  esac
done

# ============================
# Paths and files.
# ============================
JSON_SCHEMA_DIR="$WORK_DIR/json-schema"
JSON_SCHEMA_ARRAY=(
    "full-text.json"
    "images-information.json"
    "bibliographic-items.json"
    "pat-appd.json"
    "pat-amnd.json"
    "pat-rspn.json"
    "pat-etc.json"
    "application-body.json"
    "foreign-language-body.json"
    "cpy-ntc-pt-e.json"
    "cpy-ntc-pt-e-rn.json"
    "cpy-ntc-pt-f.json"
    "pat_common.json"
)
BUILD_SCHEMA="$PROJECT_ROOT/scripts/build-schema.sh"
BUILD_TS_SCHEMA="$PROJECT_ROOT/scripts/build-ts-schema.sh"
BUILD_TS_GUARD="$PROJECT_ROOT/scripts/build-ts-guard.sh"
XSL_ROOT="$PROJECT_ROOT/src/queen/stylesheets/2.0"
PANTHER_SCHEMA="$WORKSPACE_ROOT/panther/src/panther/models/generated/json-schema"
FOX_SCHEMA="$WORKSPACE_ROOT/fox/src/interfaces/generated/json-schema"

# ============================
# Step 0: Prepare directories
# ============================
log "Preparing directories"

if [ ! -d "$OUTPUT_DIR" ]; then
  mkdir -p "$OUTPUT_DIR"
fi
if [ ! -d "$WORK_DIR" ]; then
  mkdir -p "$WORK_DIR"
fi
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
# For typescript
# ============================
#if [ "$TARGET" = "typescript" ]; then
#  # ============================
#  # Step 2: Generate TypeScript types
#  # ============================
#  log "Step 2: Generating TypeScript types"
#
#  for file in "${JSON_SCHEMA_ARRAY[@]}"; do
#    base_name=$(basename "$file" .json)
#    dst_file="$OUTPUT_DIR/${base_name}.ts"
#    echo "Generating TypeScript type for $file -> $dst_file"
#    $BUILD_TS_SCHEMA "$JSON_SCHEMA_DIR/$file" "$dst_file" --unreachableDefinitions
#    if [ ! -f "$dst_file" ]; then
#      echo "ERROR: Expected JSON schema file not found for TypeScript generation: $dst_file"
#      exit 1
#    fi
#  done
#
#  # ============================
#  # Step 3: Generate TypeScript type guards
#  # ============================
#  log "Step 3: Generating TypeScript type guards"
#  
#  for file in "${JSON_SCHEMA_ARRAY[@]}"; do
#    base_name=$(basename "$file" .json)
#    dst_file="$OUTPUT_DIR/${base_name}.guard.ts"
#    $BUILD_TS_GUARD "$OUTPUT_DIR/$base_name.ts" "$dst_file" ${DEBUG:-}
#    sed -i -e 's/import/import type/g' "$dst_file"
#
#    if [ ! -f "$dst_file" ]; then
#      echo "ERROR: Expected TypeScript model file not found for type guard generation: $dst_file"
#      exit 1
#    fi
#  done
#fi
#
## ============================
## For python
## ============================
#if [ "$TARGET" = "python" ]; then
#  # ============================
#  # Step 2: Generate Python models
#  # ============================
#  log "Step 2: Generating Python models"
#  
#  for file in "${JSON_SCHEMA_ARRAY[@]}"; do
#    base_name=$(basename "$file" .json)
#    dst_file="$OUTPUT_DIR/$(echo "$base_name" | sed -e 's/-/_/g').py"
#    uv run datamodel-codegen \
#      --input "$JSON_SCHEMA_DIR/$file" \
#      --input-file-type jsonschema \
#      --output "$dst_file" \
#      --output-model-type pydantic_v2.BaseModel \
#      --formatters ruff-check ruff-format
#    if [ ! -f "$dst_file" ]; then
#      echo "ERROR: Python model generation failed for $file. Output not found: $dst_file"
#      exit 1
#    else
#      echo "Python model generated successfully: $dst_file"
#    fi
#  done
#fi

# ============================
# Done
# ============================
log "All schema builds completed successfully!"