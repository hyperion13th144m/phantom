#!/bin/bash

SCRIPT_DIR=$(dirname $0)
PROJECT_DIR="$SCRIPT_DIR/.."

# default vars.
BUILD="${1:-ALL}"
TARGET=(
  "mona-dev"
  "panther-dev"
  "fox-dev"
  "joker-dev"
  "queen-dev"
  "es-dev"
  "nginx-dev"
)

DOCKER_COMPOSE="-f $PROJECT_DIR/docker-compose.dev.yml"
if [ "$BUILD" = "ALL" ]; then
  for target in "${TARGET[@]}"; do
    docker compose $DOCKER_COMPOSE build $target
  done
else
  docker compose $DOCKER_COMPOSE build $BUILD
fi
