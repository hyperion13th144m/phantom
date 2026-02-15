#!/bin/bash
set -euo pipefail

WORK_DIR="./dist"
OUTPUT_DIR="./dist/outputs"

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
JSON_SCHEMA="$WORK_DIR/merged-schema.json"
JSON_SCHEMA_CAMEL="$WORK_DIR/merged-schema-camel.json"
JSON_SCHEMA_SNAKE="$WORK_DIR/merged-schema-snake.json"
PY_MODEL="$OUTPUT_DIR/patent_document_schema.py"
TS_MODEL="$OUTPUT_DIR/patent-document-schema.ts"
TS_GUARD="$OUTPUT_DIR/patent-document-schema.guard.ts"

STAGE1_DIR="$WORK_DIR/stage1"
STAGE2_DIR_PY="$WORK_DIR/stage2-py"
STAGE2_DIR_TS="$WORK_DIR/stage2-ts"

JSON_SCHEMA_ARRAY=(
    "fields.json"
    #"images.json"
    "procedure.json"
    "pat-appd.json"
    "pat-amnd.json"
    "pat-rspn.json"
    "pat-etc.json"
    "foreign-language-body.json"
    "cpy-ntc-pt-e.json"
    "cpy-ntc-pt-e-rn.json"
    "cpy-ntc-pt-f.json"
)

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
if [ ! -d "$STAGE1_DIR" ]; then
  mkdir -p "$STAGE1_DIR"
fi
if [ ! -d "$STAGE2_DIR_PY" ]; then
  mkdir -p "$STAGE2_DIR_PY"
fi
if [ ! -d "$STAGE2_DIR_TS" ]; then
  mkdir -p "$STAGE2_DIR_TS"
fi

# ============================
# Step 1: translate xsl as xml to json schemas.
# ============================
log "Step 1: translate xsl as xml to json schemas."
./build-schema.sh -o "$STAGE1_DIR" -x /xsl


# ============================
# For typescript
# ============================
if [ "$TARGET" = "typescript" ]; then
  # ============================
  # Step 2: Convert schema to camelCase
  # ============================
  log "Step 2: Converting schema to camelCase"
  
  for file in "$STAGE1_DIR"/*.json; do
    base_name=$(basename "$file" .json)
    dst_file="$STAGE2_DIR_TS/${base_name}.json"
    node ./src/convert-case.cjs "$file" "$dst_file" "camelCase"
    if [ ! -f "$dst_file" ]; then
      echo "ERROR: Schema camelCase conversion failed for $file. Output not found: $dst_file"
      exit 1
    else
      echo "Schema converted to camelCase successfully: $dst_file"
    fi
  done


  # ============================
  # Step 3: Generate TypeScript types
  # ============================
  log "Step 3: Generating TypeScript types"

  for file in "${JSON_SCHEMA_ARRAY[@]}"; do
    base_name=$(basename "$file" .json)
    dst_file="$OUTPUT_DIR/${base_name}.ts"
    npx json2ts "$STAGE2_DIR_TS/$file" "$dst_file" --cwd "$STAGE2_DIR_TS"
    if [ ! -f "$dst_file" ]; then
      echo "ERROR: Expected JSON schema file not found for TypeScript generation: $dst_file"
      exit 1
    else
      echo "Found JSON schema for TypeScript generation: $dst_file"
    fi
  done


  # ============================
  # Step 4: Generate TypeScript type guards
  # ============================
  log "Step 4: Generating TypeScript type guards"
  
  for file in "${JSON_SCHEMA_ARRAY[@]}"; do
    base_name=$(basename "$file" .json)
    dst_file="$OUTPUT_DIR/${base_name}.guard.ts"
    npx ts-auto-guard --export-all "$OUTPUT_DIR/$base_name.ts" "$dst_file"
    sed -i -e 's/import/import type/g' "$dst_file"

    if [ ! -f "$dst_file" ]; then
      echo "ERROR: Expected TypeScript model file not found for type guard generation: $dst_file"
      exit 1
    else
      echo "Found TypeScript model for type guard generation: $dst_file"
    fi
  done
fi

# ============================
# For python
# ============================
if [ "$TARGET" = "python" ]; then
  # ============================
  # Step 2: Convert schema to snake_case
  # ============================
  log "Step 2: Converting schema to snake_case"
  
  for file in "$STAGE1_DIR"/*.json; do
    base_name=$(basename "$file" .json)
    dst_file="$STAGE2_DIR_PY/${base_name}.json"
    #node ./src/convert-case.cjs "$file" "$dst_file" "snake_case"
    if [ ! -f "$dst_file" ]; then
      echo "ERROR: Schema snake_case conversion failed for $file. Output not found: $dst_file"
      exit 1
    else
      echo "Schema converted to snake_case successfully: $dst_file"
    fi
  done

  # ============================
  # Step 3: Generate Python models
  # ============================
  log "Step 3: Generating Python models"
  
  for file in "${JSON_SCHEMA_ARRAY[@]}"; do
    base_name=$(basename "$file" .json)
    dst_file="$OUTPUT_DIR/${base_name}.py"
    echo "$STAGE2_DIR_PY/$file"
    datamodel-codegen \
      --input "$STAGE2_DIR_PY/$file" \
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