#!/bin/bash

XSL=${1:-./src/schema-dsl.xsl}
SRC_XML=${2:-/xsl/pat-appd.xsl}
OUT_JSON=${3:-./dist/pat-appd.json}

java -cp /opt/saxon-he/saxon-he-10.8.jar net.sf.saxon.Transform \
  -xsl:$XSL \
  -s:$SRC_XML \
  -o:$OUT_JSON --allowSyntaxExtensions:off 
jq . $OUT_JSON > "${OUT_JSON}.tmp" && mv "${OUT_JSON}.tmp" $OUT_JSON
