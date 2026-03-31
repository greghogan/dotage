TODAY=`date +%Y%m%d`
TAG=ghcr.io/greghogan/dotage/apache-arrow-source-with-thirdparty-dependencies:${TODAY}

docker build -f Dockerfile -t $TAG /efs/devel
