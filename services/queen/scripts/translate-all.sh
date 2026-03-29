#!/bin/bash

T=${1:-1}
export T
source .envrc
SRC_XML=$(find $SRC -type f -name "*.xml")

if [ ! -d "$OUT" ]; then
    echo "Output directory does not exist. Creating it."
    mkdir -p "$OUT"
fi
if [ "$2" = "--debug" ]; then
    uv run src/queen/translate_all.py $SRC_XML --output-dir $OUT --debug
#    for f in $OUT/*.json; do
#        echo "Prettifying $f"
#        jq . $f > tmp.$$.json && mv tmp.$$.json $f
#    done
else
    uv run src/queen/translate_all.py $SRC_XML --output-dir $OUT --prettify
fi
