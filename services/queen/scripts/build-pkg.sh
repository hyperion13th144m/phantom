#!/bin/bash

if [ "$1" = "patch" ]; then
  uv version --bump patch
fi
uv build -o /pkgs
