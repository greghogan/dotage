#!/bin/bash -x

# exit immediately on failure (even when piping) and treat unset variables and
# parameters as an error
set -euo pipefail

# current base image options from https://hub.docker.com/_/rust:
#   alpine    Alpine Linux
#   bookworm  Debian 12
#   bullseye  Debian 11
BASE_IMAGE=alpine

TAG=ghcr.io/greghogan/dotage/apache-arrow-ballista-cli:latest

docker build --build-arg BASE_IMAGE=${BASE_IMAGE} --tag $TAG .
