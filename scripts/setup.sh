#!/bin/bash

SCRIPT_DIR=$(dirname $0)
_PROJECT_ROOT=$(dirname "$SCRIPT_DIR")
PROJECT_ROOT=$(readlink -f "$_PROJECT_ROOT")

MODE=${1:-production}

echo "Setting up elasticsearch"
$SCRIPT_DIR/es.sh -m $MODE

echo "Setting up extra-data"
$SCRIPT_DIR/extra-data.sh -m $MODE
