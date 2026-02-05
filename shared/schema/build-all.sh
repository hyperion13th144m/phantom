#!/bin/sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

# ============================
# Utility
# ============================
log() {
  echo ""
  echo "========================================"
  echo "$1"
  echo "========================================"
}

# ============================
# Paths
# ============================
SCHEMA_SRC="./src"
SCHEMA_DIST="./dist/patent-document-schema.json"

FOX_TYPES="../../fox/src/interfaces/patent-document-schema.ts"
MONA_MODEL="../../mona/src/mona/models/patent_document_schema.py"
PANTHER_MODEL="../../panther/src/panther/models/patent_document.py"
TS_MODEL="./dist/patent-document-schema.ts"
PY_MODEL="./dist/patent_document_schema.py"

# ============================
# Step 0: Prepare directories
# ============================
log "Preparing directories"

mkdir -p ./dist
mkdir -p "$(dirname "$FOX_TYPES")"
mkdir -p "$(dirname "$MONA_MODEL")"
mkdir -p "$(dirname "$PANTHER_MODEL")"

# ============================
# Step 1: Merge schema
# ============================
log "Step 1: Merging schema YAML files"

node build-schema.js "$SCHEMA_SRC" "$SCHEMA_DIST"

if [ ! -f "$SCHEMA_DIST" ]; then
  echo "ERROR: Schema merge failed. Output not found: $SCHEMA_DIST"
  exit 1
fi

# ============================
# Step 2: Generate TypeScript types
# ============================
log "Step 2: Generating TypeScript types for fox"

json2ts \
  -i "$SCHEMA_DIST" \
  -o "$FOX_TYPES"

# ============================
# Step 3: Generate Python models
# ============================
log "Step 3: Generating Python models for mona"

datamodel-codegen \
  --input "$SCHEMA_DIST" \
  --input-file-type jsonschema \
  --output "$MONA_MODEL" \
  --output-model-type pydantic_v2.BaseModel \
  --formatters ruff-check ruff-format

log "Step 4: Generating Python models for panther"

datamodel-codegen \
  --input "$SCHEMA_DIST" \
  --input-file-type jsonschema \
  --output "$PANTHER_MODEL" \
  --output-model-type pydantic_v2.BaseModel \
  --formatters ruff-check ruff-format

log "Step 5: Generating Python models for test"
datamodel-codegen \
  --input "$SCHEMA_DIST" \
  --input-file-type jsonschema \
  --output "$PY_MODEL" \
  --output-model-type pydantic_v2.BaseModel \
  --formatters ruff-check ruff-format

log "Step 6: Generating TypeScript types for test"
json2ts \
  -i "$SCHEMA_DIST" \
  -o "$TS_MODEL"

# ============================
# Done
# ============================
log "All schema builds completed successfully!"