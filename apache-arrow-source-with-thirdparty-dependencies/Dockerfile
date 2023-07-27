FROM alpine:latest
WORKDIR /work
ARG version

# download and unpackage Apache Arrow source
RUN wget https://github.com/apache/arrow/archive/refs/tags/apache-arrow-${version}.tar.gz
RUN mkdir apache-arrow-${version}
RUN tar xf apache-arrow-${version}.tar.gz --directory apache-arrow-${version} --strip-components=1
RUN rm apache-arrow-${version}.tar.gz

# download_dependencies.sh shebangs bash, coreutils provides tee
RUN apk add bash coreutils
# fetch third party dependencies, saving environmental variables from script output
RUN ./apache-arrow-${version}/cpp/thirdparty/download_dependencies.sh thirdparty-dependencies | tee env.sh

# create single-layer image with only copied artifacts
FROM scratch
COPY --from=0 /work ./
