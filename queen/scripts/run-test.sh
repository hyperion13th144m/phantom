#!/bin/bash

SCRIPT_DIR="$(dirname $0)"
PROJECT_ROOT="$SCRIPT_DIR/.."
cd $PROJECT_ROOT || exit 1

uv run pytest tests/test_translate_all.py -v
