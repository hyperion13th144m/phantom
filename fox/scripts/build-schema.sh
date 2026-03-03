#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/.."

cd "$PROJECT_ROOT" || exit 1

DEBUG=${1:-}
JSON_SCHEMA_DIR="$PROJECT_ROOT/src/interfaces/generated/json-schema"
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
    "dispatch-control-article.json"
)
OUTPUT_DIR="$PROJECT_ROOT/src/interfaces/generated"
# ============================
# Step 1: Generate TypeScript types
# ============================
echo "Step 1: Generating TypeScript types"

for file in "${JSON_SCHEMA_ARRAY[@]}"; do
  base_name=$(basename "$file" .json)
  dst_file="$OUTPUT_DIR/${base_name}.ts"
  echo "Generating TypeScript type for $file -> $dst_file"
  npx json2ts "$JSON_SCHEMA_DIR/$file" "$dst_file" --cwd "$JSON_SCHEMA_DIR" --unreachableDefinitions
  if [ ! -f "$dst_file" ]; then
    echo "ERROR: Expected JSON schema file not found for TypeScript generation: $dst_file"
    exit 1
  fi
done

# ============================
# Step 2: Generate TypeScript type guards
# ============================
echo "Step 2: Generating TypeScript type guards"

for file in "${JSON_SCHEMA_ARRAY[@]}"; do
  base_name=$(basename "$file" .json)
  dst_file="$OUTPUT_DIR/${base_name}.guard.ts"
  if [ -z "$DEBUG" ]; then
    DEBUG_OPT=""
  else
    DEBUG_OPT="--debug"
  fi
  npx ts-auto-guard ${DEBUG_OPT} --export-all "$OUTPUT_DIR/$base_name.ts" "$dst_file"
  sed -i -e 's/import/import type/g' "$dst_file"

  if [ ! -f "$dst_file" ]; then
    echo "ERROR: Expected TypeScript model file not found for type guard generation: $dst_file"
    exit 1
  fi
done
