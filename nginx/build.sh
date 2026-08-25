#!/bin/bash

source ../common.sh

docker build . --build-arg BASE_IMAGE=$os_image -t $nginx_image --no-cache -f kylin-V10SP2.nginx.Dockerfile
docker push $nginx_image

