#!/bin/bash

SCRIPT_DIR="$(dirname $0)"
PROJECT_ROOT="$SCRIPT_DIR/.."
cd $PROJECT_ROOT || exit 1

uv run pytest tests/test_parse.py -v

# individual test
# uv run pytest tests/test_parse.py::test_parse[notice/a101-1] -v