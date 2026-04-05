#!/bin/bash

# generate OpenAPI client code for
# developing project using the OpenAPI.
# the code will be used for buildng package.

SCRIPT_DIR=$(dirname "$0")
PROJECT_ROOT=$(dirname "$SCRIPT_DIR")

# default vars.
BUILD="${1:-ALL}"
ALL_TARGET=(
  "crow"
)

declare -A SRC_DIR=(
  ["crow"]="$PROJECT_ROOT/services/crow"
)

if [ "$BUILD" = "ALL" ]; then
  TARGET=("${ALL_TARGET[@]}")
else
  TARGET=($BUILD)
fi

for target in "${TARGET[@]}"; do
  OPENAPI_FILE=$(readlink -f $PROJECT_ROOT/api/$target.json)
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

  popd > /dev/null 


  echo "Done generating OpenAPI schema $target."
done
