#!/bin/bash -x

# exit immediately on failure (even when piping), treat unset variables and
# parameters as an error, and disable filename expansion (globbing)
set -eufo pipefail

for YEAR in `seq 2009 $(date +%Y)`; do
  TAG=ghcr.io/greghogan/dotage/nyc-tlc-trip-record-data:${YEAR}
  docker build --build-arg years=${YEAR} --tag $TAG .
done
