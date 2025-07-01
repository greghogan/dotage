#!/usr/bin/env sh

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# exit immediately on failure (even when piping), and treat unset variables and
# parameters as an error
set -euo pipefail

MOUNT_DIR=/volumes/nvme1n1
PACK_DIR=${MOUNT_DIR}/pack
DATE=`date +%Y%m%d`

unset GUIX_BUILD_OPTIONS

usage() {
  echo "Usage: $0 [-a|--arch <arch>] [-c|--commit commit] <package> [<package> ...]"
}

if [ $# -lt 1 ]; then
  usage >&2
  exit 1
fi

POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -a|--arch)
      ARCH_ARG="$2"
      shift
      shift
      ;;
    -c|--commit)
      COMMIT_ARG="$2"
      shift
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1")
      shift
      ;;
  esac
done


DEFAULT_ARCH="`uname -m`"
ARCH=${ARCH_ARG:-${DEFAULT_ARCH}}
echo "Arch: ${ARCH}"


DEFAULT_COMMIT=""
COMMIT=${COMMIT_ARG:-${DEFAULT_COMMIT}}
echo "Commit: ${COMMIT}"

if [ -z "$COMMIT" ]; then
  PREFIX="guix"
else
  PREFIX="guix time-machine --commit=${COMMIT} --"
fi


PACKAGES="${POSITIONAL_ARGS[@]}"
echo "Packages: ${PACKAGES}"

PROFILE=profile
$PREFIX \
  build \
  --root=${PROFILE} \
  --keep-going \
  --verbosity=1 \
  ${PACKAGES}


SYMLINKS=""
for DIR in "bin" "sbin"; do
  if [ -e ${PROFILE}/${DIR} ]; then
    SYMLINKS="${SYMLINKS} --symlink=/${DIR}=${DIR}"
  fi
done
echo "Symlinks: ${SYMLINKS}"

rm -f "${PROFILE}"


if [ -z "$COMMIT" ]; then
  PREFIX="guix"
else
  PREFIX="guix time-machine --commit=${COMMIT} --"
fi

$PREFIX \
  pack \
  --system="${ARCH}-linux" \
  --format=docker \
  --compression=zstd \
  --save-provenance \
  $SYMLINKS \
  --keep-going \
  --verbosity=1 \
  ${PACKAGES}
