#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.." || exit 1
if [ "$1" == "--debug" ]; then
  DEBUG="-d"
fi

./scripts/build-all.sh -o "$(pwd)/../fox/src/interfaces/generated/" ${DEBUG:-} typescript
