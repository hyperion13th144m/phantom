#!/bin/bash

# This script builds the patent document schema
# by translating XML to JSON files and merging json files.


XSL_ROOT="/xsl"
SRC_XML_ARRAY=(
    "pat-appd.xsl"
    "pat-amnd.xsl"
    "pat-rspn.xsl"
    "pat-etc.xsl"
    "fields.xsl"
    "foreign-language-body.xsl"
    "v4xva_ntc-pt-e.xsl"
    "v4xva_ntc-pt-e-rn.xsl"
    "ntc-ninsyo.xsl"
    "common-templates/dispatch-control-article.xsl"
    "common-templates/pat_common.xsl"
)
DSL="./src/schema-dsl.xsl"
DST_ROOT=${1:-"./dist"}
GENERATED_SCHEMA_DIR="$DST_ROOT/generated-schemas"

if [ ! -d "$GENERATED_SCHEMA_DIR" ]; then
    mkdir -p "$GENERATED_SCHEMA_DIR"
fi

# Translate each XML file to JSON using the XSLT.
for src_xml in "${SRC_XML_ARRAY[@]}"; do
    base_name=$(basename "$src_xml" .xsl)
    dst_json="$GENERATED_SCHEMA_DIR/${base_name}.json"
    echo "Translating $src_xml to $dst_json"

    # read xsl as xml and translate them to json using the DSL
    python ./src/translate_xml.py "$XSL_ROOT/$src_xml" "$DSL" "$dst_json"
done

# Merge all generated json files into a single schema file
MERGED_SCHEMA="$DST_ROOT/merged-schema.json"
echo "Merging generated schemas into $MERGED_SCHEMA"    
jq -s 'reduce .[] as $item ({}; . * $item)' \
  src/root.json \
  $GENERATED_SCHEMA_DIR/*.json \
  > "$MERGED_SCHEMA"
