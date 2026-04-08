#!/bin/bash


echo log_dir = $LOG_DIR
echo log_level = $LOG_LEVEL
echo data_root = $DATA_ROOT

if [ -z "$DATA_ROOT" ]; then
  echo "DATA_ROOT must be set."
  exit 1
fi

uv run uvicorn mona.server:app --host 0.0.0.0 --port 8000 --reload
