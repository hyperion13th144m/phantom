#!/bin/bash

T=${1:-1}
source .envrc
if [ -z "$SRC" ] || [ -z "$DST" ] || [ -z "$CODE" ]; then
  echo "Invalid input. Please provide a valid number between 1 and 12."
  exit 1
fi

if [ ! -d "$DST" ]; then
  mkdir -p "$DST"
fi
uv run crow-cli -s $SRC -d $DST -c $CODE
