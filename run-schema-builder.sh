#!/bin/sh

SCRIPT_DIR=$(dirname $0)

XSL_MOUNT=./mona/src/mona/stylesheets/1.0:/xsl:ro
FOX_MOUNT=./fox/src/interfaces/generated:/generated
MONA_MOUNT=./mona/src/mona/models/generated:/generated
PANTHER_MOUNT=./panther/src/panther/models/generated:/generated
OPTS="-w /tmp -o /generated"

if [ "$1" = "build" ]; then
  docker build -t schema-builder shared/schema
fi

docker run --rm -it \
  -v $XSL_MOUNT -v $FOX_MOUNT \
  schema-builder $OPTS typescript

docker run --rm -it \
  -v $XSL_MOUNT -v $MONA_MOUNT \
  schema-builder $OPTS python

docker run --rm -it \
  -v $XSL_MOUNT -v $PANTHER_MOUNT \
  schema-builder $OPTS python

