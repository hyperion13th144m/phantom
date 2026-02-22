#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.." || exit 1

./scripts/build-all.sh -o "$(pwd)/../fox/src/interfaces/generated/" typescript
