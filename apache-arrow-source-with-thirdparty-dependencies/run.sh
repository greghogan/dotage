#!/bin/bash -x

# exit immediately on failure (even when piping), treat unset variables and
# parameters as an error, and disable filename expansion (globbing)
set -eufo pipefail


if [ "$#" -ne 1 ]; then
  echo "usage: $0 <apache arrow version>"
  exit 1
fi

VERSION=$1


# Build the artifact container with the source code, dependency packages, and environment script.

TAG=ghcr.io/greghogan/dotage/apache-arrow-source-with-thirdparty-dependencies:${VERSION}
docker build --build-arg version=${VERSION} --tag $TAG .


# Check the build process in an offline container.

rm -rf work && mkdir work
docker save $TAG | tar --extract --to-stdout --file=- --wildcards '*/layer.tar' | tar x --directory=work

guix shell --container --development apache-arrow --preserve='^VERSION$' --no-cwd --share=work=/work -- bash <<-EOF
cd /work
. env.sh
mkdir build install
# use make since ninja may be unavailable
sed -i 's/Ninja/Unix Makefiles/' apache-arrow-${VERSION}/cpp/CMakePresets.json

# disable substrait as it is not downloaded as a third-party dependency
cmake apache-arrow-${VERSION}/cpp --preset ninja-release -B build -DCMAKE_INSTALL_PREFIX=install -DPARQUET_BUILD_EXECUTABLES=ON -DARROW_SUBSTRAIT=OFF
cmake --build build
cmake --install build
EOF

# Clean up
rm -rf work
