#!/bin/sh

if [ ! -z "$1" ]; then
    SRC="$1"
fi
if [ ! -z "$2" ]; then
    XSL="$2"
fi
if [ ! -z "$3" ]; then
    OUTPUT="$3"
fi

uv run src/queen/translate.py $SRC $XSL $OUTPUT
