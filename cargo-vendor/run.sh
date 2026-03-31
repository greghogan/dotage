#!/bin/bash -x

# exit immediately on failure (even when piping), treat unset variables and
# parameters as an error, and disable filename expansion (globbing)
set -eufo pipefail


if [ "$#" -ne 1 ]; then
  echo "usage: $0 <timestamp>"
  exit 1
fi

TIMESTAMP=$1

TAG=ghcr.io/greghogan/dotage/cargo-vendor:${TIMESTAMP}

# cleanup on interrupt
trap 'docker rm --force --volumes cargo-vendor 2>/dev/null' EXIT

docker create --name cargo-vendor $TAG "true"
docker cp cargo-vendor:/vendor-data/. ~/.cargo/vendor
