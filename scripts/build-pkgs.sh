#!/bin/bash

SCRIPT_DIR=$(dirname $0)
PROJECT_DIR="$(dirname $SCRIPT_DIR)"

# default vars.
BUILD="${1:-ALL}"
ALL_TARGET=(
  "craw"
  "queen"
)

declare -A SRC_DIR=(
  ["craw"]="$PROJECT_DIR/var/api/craw"
  ["queen"]="$PROJECT_DIR/services/queen"
)
declare -A PKG_DIR=(
  ["craw"]="$PROJECT_DIR/var/pkgs/craw"
  ["queen"]="$PROJECT_DIR/var/pkgs/queen"
)


if [ "$BUILD" = "ALL" ]; then
  TARGET=("${ALL_TARGET[@]}")
else
  TARGET=($BUILD)
fi

for target in "${TARGET[@]}"; do
  uv build --project ${SRC_DIR[$target]} -o ${PKG_DIR[$target]}
done
