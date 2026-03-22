#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(dirname $0)"
PROJECT_ROOT="$(dirname $SCRIPT_DIR)"


JSON_SCHEMA_DIR="$PROJECT_ROOT/src/panther/models/generated/json-schema"
JSON_SCHEMA_ARRAY=(
    "full-text.json"
    "images-information.json"
    "bibliographic-items.json"
)
OUTPUT_DIR="$PROJECT_ROOT/src/panther/models/generated"

for file in "${JSON_SCHEMA_ARRAY[@]}"; do
  base_name=$(basename "$file" .json)
  dst_file="$OUTPUT_DIR/$(echo "$base_name" | sed -e 's/-/_/g').py"
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
