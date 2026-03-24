#!/bin/bash

# generate OpenAPI client code for
# developing project using the OpenAPI.
# the code will be used for buildng package.

SCRIPT_DIR=$(dirname "$0")
PROJECT_ROOT=$(dirname "$SCRIPT_DIR")

# default vars.
BUILD="${1:-ALL}"
ALL_TARGET=(
  "craw"
)

declare -A SRC_DIR=(
  ["craw"]="$PROJECT_ROOT/services/craw"
)

if [ "$BUILD" = "ALL" ]; then
  TARGET=("${ALL_TARGET[@]}")
else
  TARGET=($BUILD)
fi

for target in "${TARGET[@]}"; do
  OPENAPI_FILE=/tmp/openapi-$target.json
  OUTPUT_DIR=$(readlink -f $PROJECT_ROOT/var/api/$target)
  LOG_DIR=$(readlink -f $PROJECT_ROOT/var/log/$target)

  pushd ${SRC_DIR[$target]} > /dev/null
  
  echo "Generating OpenAPI schema for $target..."
  env LOG_DIR=/tmp uv run python - <<PY
from $target.server import app
import json
from pathlib import Path
schema = app.openapi()
Path("$OPENAPI_FILE").write_text(json.dumps(schema, indent=2))
PY

  uv run openapi-python-client generate \
  --meta uv \
  --overwrite \
  --path $OPENAPI_FILE \
  --output-path $OUTPUT_DIR    

  version=$(sed -nE 's/^[[:space:]]*version[[:space:]]*=[[:space:]]*"([^"]+)".*/\1/p' pyproject.toml)
  sed -i -E "s/^[[:space:]]*version[[:space:]]*=[[:space:]]*\"[^\"]+\"/version = \"$version\"/g" $OUTPUT_DIR/pyproject.toml

  popd > /dev/null 

  rm -f $OPENAPI_FILE

  echo "Done generating OpenAPI client code for $target."
done
