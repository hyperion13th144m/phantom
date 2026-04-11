#!/bin/sh
set -eu

SQLITE_PATH="${SQLITE_PATH:-./sqlite/skull.db}"
export SQLITE_PATH

if [ ! -f "$SQLITE_PATH" ]; then
  mkdir -p "$(dirname "$SQLITE_PATH")"
  ./node_modules/.bin/tsx ./scripts/init-db.ts
fi

exec node server.js
