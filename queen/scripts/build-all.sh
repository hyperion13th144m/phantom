#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/.."
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
  echo "Usage: $0 [ -o output_dir ] [ -w work_dir ] python|typescript"
  echo "This script builds the patent document schema by translating XML to JSON files and merging them."
}

while getopts "hw:o:" opt; do
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
    *)
      echo "Invalid option: -$OPTARG" >&2
      usage
      exit 1
      ;;
  esac
done

shift $((OPTIND -1))
TARGET="$1"
if [ "$TARGET" != "python" ] && [ "$TARGET" != "typescript" ]; then
  echo "Invalid target: $TARGET"
  usage
  exit 1
fi

# ============================
# Paths and files.
# ============================
JSON_SCHEMA_DIR="$WORK_DIR/json-schema"

JSON_SCHEMA_ARRAY=(
    "full-text.json"
    "images-information.json"
    "procedure.json"
    "pat-appd.json"
    "pat-amnd.json"
    "pat-rspn.json"
    "pat-etc.json"
    "application-body.json"
    "foreign-language-body.json"
    "cpy-ntc-pt-e.json"
    "cpy-ntc-pt-e-rn.json"
    "cpy-ntc-pt-f.json"
)
BUILD_SCHEMA="$PROJECT_ROOT/scripts/build-schema.sh"
BUILD_TS_SCHEMA="$PROJECT_ROOT/scripts/build-ts-schema.sh"
BUILD_TS_GUARD="$PROJECT_ROOT/scripts/build-ts-guard.sh"
XSL_ROOT="$PROJECT_ROOT/src/queen/stylesheets/2.0"

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


# ============================
# Step 1: translate xsl as xml to json schemas.
# ============================
log "Step 1: translate xsl as xml to json schemas."
"$BUILD_SCHEMA" -o "$JSON_SCHEMA_DIR" -x "$XSL_ROOT"


# ============================
# For typescript
# ============================
if [ "$TARGET" = "typescript" ]; then
  # ============================
  # Step 2: Generate TypeScript types
  # ============================
  log "Step 2: Generating TypeScript types"

  for file in "${JSON_SCHEMA_ARRAY[@]}"; do
    base_name=$(basename "$file" .json)
    dst_file="$OUTPUT_DIR/${base_name}.ts"
    echo "Generating TypeScript type for $file -> $dst_file"
    $BUILD_TS_SCHEMA "$JSON_SCHEMA_DIR/$file" "$dst_file"
    if [ ! -f "$dst_file" ]; then
      echo "ERROR: Expected JSON schema file not found for TypeScript generation: $dst_file"
      exit 1
    fi
  done

  # ============================
  # Step 3: Generate TypeScript type guards
  # ============================
  log "Step 3: Generating TypeScript type guards"
  
  for file in "${JSON_SCHEMA_ARRAY[@]}"; do
    base_name=$(basename "$file" .json)
    dst_file="$OUTPUT_DIR/${base_name}.guard.ts"
    $BUILD_TS_GUARD "$OUTPUT_DIR/$base_name.ts" "$dst_file"
    sed -i -e 's/import/import type/g' "$dst_file"

    if [ ! -f "$dst_file" ]; then
      echo "ERROR: Expected TypeScript model file not found for type guard generation: $dst_file"
      exit 1
    fi
  done
fi

# ============================
# For python
# ============================
if [ "$TARGET" = "python" ]; then
  # ============================
  # Step 2: Generate Python models
  # ============================
  log "Step 2: Generating Python models"
  
  for file in "${JSON_SCHEMA_ARRAY[@]}"; do
    base_name=$(basename "$file" .json)
    dst_file="$OUTPUT_DIR/${base_name}.py"
    uv run datamodel-codegen \
      --input "$JSON_SCHEMA_DIR/$file" \
      --input-file-type jsonschema \
      --output "$dst_file" \
      --output-model-type pydantic_v2.BaseModel \
      --formatters ruff-check ruff-format
    if [ ! -f "$dst_file" ]; then
      echo "ERROR: Python model generation failed for $file. Output not found: $dst_file"
      exit 1
    else
      echo "Python model generated successfully: $dst_file"
    fi
  done
fi

# ============================
# Done
# ============================
log "All schema builds completed successfully!"