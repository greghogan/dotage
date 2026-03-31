#!/bin/bash -x

# exit immediately on failure (even when piping), treat unset variables and
# parameters as an error, and disable filename expansion (globbing)
set -eufo pipefail

TIMESTAMP=`date +%Y%m%d-%H%M%S`
TAG=ghcr.io/greghogan/dotage/cargo-vendor:$TIMESTAMP

docker build -f Dockerfile -t $TAG /efs/devel
