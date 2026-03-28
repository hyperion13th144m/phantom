#!/bin/bash

T=${1:-1}
source .envrc
uv run crow-cli -s $SRC -d $DST -c $CODE
