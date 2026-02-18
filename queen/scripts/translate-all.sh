#!/bin/sh

SRC_XML_DIR=$1
SRC_XML=$(find $SRC_XML_DIR -type f -name "*.xml")
OUTPUT_DIR=$2
if [ -z "$OUTPUT_DIR" ]; then
    echo "Output directory not specified. Exiting."
    exit 1
fi
if [ ! -d "$OUTPUT_DIR" ]; then
    echo "Output directory does not exist. Creating it."
    mkdir -p "$OUTPUT_DIR"
fi
uv run src/queen/translate_all.py $SRC_XML --output-dir $OUTPUT_DIR --prettify
