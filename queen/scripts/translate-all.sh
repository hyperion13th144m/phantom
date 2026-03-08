#!/bin/sh

SRC_XML_DIR=$1
SRC_XML=$(find $SRC_XML_DIR -type f -name "*.xml")
OUTPUT_SUB_DIR=$(basename $SRC_XML_DIR)
OUTPUT_DIR=$2/$OUTPUT_SUB_DIR

if [ -z "$OUTPUT_DIR" ]; then
    echo "Output directory not specified. Exiting."
    exit 1
fi
if [ ! -d "$OUTPUT_DIR" ]; then
    echo "Output directory does not exist. Creating it."
    mkdir -p "$OUTPUT_DIR"
fi
if [ "$3" = "--debug" ]; then
    uv run src/queen/translate_all.py $SRC_XML --output-dir $OUTPUT_DIR --debug
    for f in $OUTPUT_DIR/*.json; do
        echo "Prettifying $f"
        jq . $f > tmp.$$.json && mv tmp.$$.json $f
    done
else
    uv run src/queen/translate_all.py $SRC_XML --output-dir $OUTPUT_DIR --prettify
fi
