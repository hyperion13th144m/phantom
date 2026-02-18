#!/bin/bash

# This script builds the patent document schema
# by translating XSL as XML to JSON files.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.." || exit 1
OUTPUT_DIR="./out/generated-schema"
XSL_ROOT="./stylesheets/2.0"
SRC_XML_ARRAY=(
    "fields.xsl"
    "images.xsl"
    "procedure.xsl"
    "pat-appd.xsl"
    "pat-amnd.xsl"
    "pat-rspn.xsl"
    "pat-etc.xsl"
    "application-body.xsl"
    "foreign-language-body.xsl"
    "cpy-ntc-pt-e.xsl"
    "cpy-ntc-pt-e-rn.xsl"
    "cpy-ntc-pt-f.xsl"
    "common-templates/pat_common.xsl"
    "v4xva_ntc-pt-e.xsl"
    "v4xva_ntc-pt-e-rn.xsl"
    "v4xva_ntc-pt-f.xsl"
    "common-templates/ntc-ninsyo.xsl"
    "common-templates/ntc-paragraph.xsl"
    "common-templates/dispatch-control-article.xsl"
    "common-templates/unsupported-tags.xsl"
)
DSL="./stylesheets/schema/schema-dsl.xsl"

usage() {
  echo "Usage: $0 [ -o output_dir ] [ -x xsl_root ] [ -s schema_xsl ]"
  echo "This script builds the patent document schema by translating XML to JSON files."
}

while getopts "hx:o:s:" opt; do
  case $opt in
    h)
      usage
      exit 0
      ;;
    x)
      echo "Option -x with argument: $OPTARG"
      XSL_ROOT="$OPTARG"
      ;;
    o)
      echo "Option -o with argument: $OPTARG"
      OUTPUT_DIR="$OPTARG"
      ;;
    s)
      echo "Option -s with argument: $OPTARG"
      SRC_XML_ARRAY=("$OPTARG")
      ;;
    *)
      echo "Invalid option: -$OPTARG" >&2
      usage
      exit 1
      ;;
  esac
done

if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR"
fi

# Translate each XML file to JSON using the XSLT.
for src_xml in "${SRC_XML_ARRAY[@]}"; do
    base_name=$(basename "$src_xml" .xsl)
    dst_json="$OUTPUT_DIR/${base_name}.json"
    echo "Translating $src_xml to $dst_json"

    # read xsl as xml and translate them to json using the DSL
    uv run src/queen/translate.py \
       "$XSL_ROOT/$src_xml" \
       "$DSL" \
       "$dst_json" --prettify
done
