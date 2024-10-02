ARG BASE_IMAGE=alpine

FROM rust:${BASE_IMAGE}

# https://docs.docker.com/reference/dockerfile/#understand-how-arg-and-from-interact
ARG BASE_IMAGE

# Alpine Linux dependencies:
#   musl-dev as fix for "x86_64-alpine-linux-musl/bin/ld: cannot find crti.o: No such file or directory"
#   protoc as fix for "error: failed to run custom build command for `etcd-client v...`"
#
# Debian Linux dependencies:
#   protobuf-compiler as fix for "error: failed to run custom build command for `etcd-client v...`"

RUN echo ${BASE_IMAGE}; if [ "$BASE_IMAGE" = "alpine" ]; then \
  apk add --no-cache \
    musl-dev \
    protoc \
; else \
  apt-get update && apt-get install -y \
    protobuf-compiler \
  && rm -rf /var/lib/apt/lists/* \
; fi

RUN cargo install ballista-cli

CMD ["ballista-cli"]
