#!/bin/bash

SCRIPT_DIR=$(dirname "$0")
PROJECT_ROOT=$(dirname "$SCRIPT_DIR")

DIST=/pkgs
CLIENT_DIR=/export-api
OPENAPI_FILE=/tmp/openapi.json

echo "Generating OpenAPI client..."
echo "  PROJECT_ROOT=$PROJECT_ROOT"
echo "  DIST=$DIST"
echo "  CLIENT_DIR=$CLIENT_DIR"

echo "Generating OpenAPI schema..."
uv run python - <<PY
from craw.server import app
import json
from pathlib import Path
schema = app.openapi()
Path("$OPENAPI_FILE").write_text(json.dumps(schema, indent=2))
PY

echo "Generating OpenAPI client code..."
uv run openapi-python-client generate \
  --overwrite \
  --path $OPENAPI_FILE \
  --output-path $CLIENT_DIR    

version=$(sed -nE 's/^[[:space:]]*version[[:space:]]*=[[:space:]]*"([^"]+)".*/\1/p' pyproject.toml)
echo "Updating client version to $version..."
sed -i -E "s/^[[:space:]]*version[[:space:]]*=[[:space:]]*\"[^\"]+\"/version = \"$version\"/g" $CLIENT_DIR/pyproject.toml

echo "Building OpenAPI client..."
uv build $CLIENT_DIR -o $DIST
