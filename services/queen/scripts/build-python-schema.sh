#!/bin/bash

SCRIPT_DIR="$(dirname $0)"
PROJECT_ROOT="$(dirname $SCRIPT_DIR)"

# ============================
# Paths and files.
# ============================
JSON_SCHEMA_DIR="$PROJECT_ROOT/generated/json-schema"
OUTPUT_DIR="$PROJECT_ROOT/generated/python"
JSON_SCHEMA_ARRAY=(
    "full-text.json"
    "images-information.json"
    "bibliographic-items.json"
)

usage() {
  echo "Usage: $0 [ -o output_dir ] [ -h ]"
  echo "This script builds the patent document schema for python."
}

while getopts "ho:" opt; do
  case $opt in
    h)
      usage
      exit 0
      ;;
    o)
      echo "Option -o with argument: $OPTARG"
      OUTPUT_DIR="$OPTARG"
      ;;
    *)
      echo "Invalid option: -$OPTARG" >&2
      usage
      exit 1
      ;;
  esac
done

if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR"
fi


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
