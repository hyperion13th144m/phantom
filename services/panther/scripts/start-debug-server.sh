#!/bin/bash


echo log_dir = $LOG_DIR
echo log_level = $LOG_LEVEL
echo es_url = $ES_URL
echo api_key = $ES_API_KEY
echo es_user = $ES_USER
echo es_password = $ES_PASSWORD
echo mona_url = $MONA_URL
echo data_root = $DATA_ROOT
echo index = $ES_INDEX

if [ -z "$DATA_ROOT" ] && [ -z "$MONA_URL" ]; then
  echo "Either DATA_ROOT or MONA_URL must be set."
  exit 1
fi

# panther.server:app will exit if both $DATA_ROOT and $MONA_URL are not.
# but with --reload option, uvicorn will not stop regardless of
# whether the app stopped. uvicorn continue to run and wait for restart of the app.
uv run uvicorn panther.server:app --host 0.0.0.0 --port 8000 --reload
