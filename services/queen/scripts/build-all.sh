#!/bin/bash

SCRIPT_DIR="$(dirname $0)"

$SCRIPT_DIR/build-json-schema.sh
$SCRIPT_DIR/build-python-schema.sh
$SCRIPT_DIR/build-ts-schema.sh
$SCRIPT_DIR/copy-python-schema.sh
$SCRIPT_DIR/copy-ts-schema.sh
