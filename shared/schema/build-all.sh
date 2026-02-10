#!/bin/sh
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
# Paths
# ============================
JSON_SCHEMA="$WORK_DIR/merged-schema.json"
JSON_SCHEMA_CAMEL="$WORK_DIR/merged-schema-camel.json"
JSON_SCHEMA_SNAKE="$WORK_DIR/merged-schema-snake.json"
PY_MODEL="$OUTPUT_DIR/patent_document_schema.py"
TS_MODEL="$OUTPUT_DIR/patent-document-schema.ts"
TS_GUARD="$OUTPUT_DIR/patent-document-schema.guard.ts"


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

# ============================
# Step 1: translate xsl as xml to json schemas and merge them to a single json schema 
# ============================
log "Step 1: translate xsl as xml to json schemas and merge them to a single json schema."
./merge-schemas.sh "$WORK_DIR"



if [ "$TARGET" = "typescript" ]; then
  # ============================
  # Step 2: Convert schema to camelCase
  # ============================
  log "Step 2: Converting schema to camelCase"
  
  node ./src/convert-case.cjs "$JSON_SCHEMA" "$JSON_SCHEMA_CAMEL" "camelCase"
  
  if [ ! -f "$JSON_SCHEMA_CAMEL" ]; then
    echo "ERROR: Schema camelCase conversion failed. Output not found: $JSON_SCHEMA_CAMEL"
    exit 1
  fi

  # ============================
  # Step 3: Generate TypeScript types
  # ============================
  log "Step 3: Generating TypeScript types"
  node ./src/to-ts-schema.cjs "$JSON_SCHEMA_CAMEL" "$TS_MODEL"
  if [ ! -f "$TS_MODEL" ]; then
    echo "ERROR: TypeScript type generation failed. Output not found: $TS_MODEL"
    exit 1
  else
    echo "TypeScript types generated successfully: $TS_MODEL"
  fi

  # ============================
  # Step 4: Generate TypeScript type guards
  # ============================
  log "Step 4: Generating TypeScript type guards"
  
  yarn run ts-auto-guard --export-all "$TS_MODEL" "$TS_GUARD"
  sed -i -e 's/import/import type/g' "$TS_GUARD"
  if [ ! -f "$TS_GUARD" ]; then
    echo "ERROR: TypeScript type guard generation failed. Output not found: $TS_GUARD"
    exit 1
  else
    echo "TypeScript type guards generated successfully: $TS_GUARD"
  fi
fi

if [ "$TARGET" = "python" ]; then
  # ============================
  # Step 2: Convert schema to snake_case
  # ============================
  log "Step 2: Converting schema to snake_case"
  
  node ./src/convert-case.cjs "$JSON_SCHEMA" "$JSON_SCHEMA_SNAKE" "snake_case"
  
  if [ ! -f "$JSON_SCHEMA_SNAKE" ]; then
    echo "ERROR: Schema snake_case conversion failed. Output not found: $JSON_SCHEMA_SNAKE"
    exit 1
  else
    echo "Schema converted to snake_case successfully: $JSON_SCHEMA_SNAKE"
  fi

  # ============================
  # Step 5: Generate Python models
  # ============================
  log "Step 3: Generating Python models"
  
  datamodel-codegen \
    --input "$JSON_SCHEMA_SNAKE" \
    --input-file-type jsonschema \
    --output "$PY_MODEL" \
    --output-model-type pydantic_v2.BaseModel \
    --formatters ruff-check ruff-format
  if [ ! -f "$PY_MODEL" ]; then
    echo "ERROR: Python model generation failed. Output not found: $PY_MODEL"
    exit 1
  else
    echo "Python models generated successfully: $PY_MODEL"
  fi
fi

# ============================
# Done
# ============================
log "All schema builds completed successfully!"