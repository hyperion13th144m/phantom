#!/bin/bash

SCRIPT_DIR=$(dirname $0)
PROJECT_DIR="$(dirname $SCRIPT_DIR)"

# default vars.
BUILD="${1:-ALL}"
ALL_TARGET=(
  "mona-dev"
  "craw-dev"
  "panther-dev"
  "fox-dev"
  "joker-dev"
  "queen-dev"
  "es-dev"
  "nginx-dev"
)

prep_craw() {
  echo "Preparing craw-dev image..."
  $SCRIPT_DIR/build-pkgs.sh queen
  cp $PROJECT_DIR/var/pkgs/queen/queen-*.whl $PROJECT_DIR/services/craw/deps/
}

DOCKER_COMPOSE="-f $PROJECT_DIR/docker-compose.dev.yml"
if [ "$BUILD" = "ALL" ]; then
  TARGET=("${ALL_TARGET[@]}")
else
  TARGET=($BUILD)
fi

for target in "${TARGET[@]}"; do
    if [ "$target" = "craw-dev" ]; then
        prep_craw
    fi
    docker compose $DOCKER_COMPOSE build $target
done
