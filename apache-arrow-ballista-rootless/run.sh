#!/bin/bash -x

# exit immediately on failure (even when piping) and treat unset variables and
# parameters as an error
set -euo pipefail


if [ "$#" -ne 1 ]; then
  echo "usage: $0 <apache arrow ballista version>"
  exit 1
fi

VERSION=$1


# Download and checkout requested version

git clone https://github.com/apache/arrow-ballista.git
cd arrow-ballista

git checkout $VERSION

# Move binaries and encrypoint scripts to non-root readable paths.

sed -i 's%root%usr/local/bin%g' dev/docker/*.Dockerfile dev/docker/*.sh

# Switch privileged port to ephemeral port

sed -i 's/80/8080/g' dev/docker/nginx.conf dev/docker/scheduler-entrypoint.sh dev/docker/ballista-scheduler.Dockerfile dev/docker/ballista-standalone.Dockerfile

# Build and tag images

./dev/build-ballista-docker.sh

docker container prune --force

# delete base images
docker image rm rust:1.74.1-buster
docker image rm ubuntu:22.04

# delete builder and duplicate 'latest images'
for COMPONENT in benchmarks builder executor scheduler; do
  docker image rm ballista-${COMPONENT}:latest
done

for COMPONENT in cli standalone benchmarks executor scheduler; do
  docker tag apache/arrow-ballista-${COMPONENT}:${VERSION} ghcr.io/greghogan/dotage/apache-arrow-ballista-rootless/${COMPONENT}:${VERSION}
  docker image rm apache/arrow-ballista-${COMPONENT}:${VERSION}
done

# Cleanup

cd ..
rm -rf arrow-ballista
