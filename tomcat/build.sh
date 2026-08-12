#!/bin/bash

source ../common.sh

docker build . --build-arg BASE_IMAGE=$dragonwell_extended11_image -t $tomcat9_image --no-cache -f kylin-V10SP2.tomcat9.Dockerfile
docker push $tomcat9_image
