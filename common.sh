#!/bin/bash

build_date=${BUILD_DATE:-$(date +"%Y%m%d")}
dockerhub_repo="ln3333/kylinos"

os_image="$dockerhub_repo:v10-sp2-amd64-$build_date"

openjdk8_image="$dockerhub_repo:v10-sp2-amd64-openjdk8-$build_date"
openjdk17_image="$dockerhub_repo:v10-sp2-amd64-openjdk17-$build_date"

openjdk8_maven3_9_image="$dockerhub_repo:v10-sp2-amd64-openjdk8-maven3.9-$build_date"
openjdk17_maven3_9_image="$dockerhub_repo:v10-sp2-amd64-openjdk17-maven3.9-$build_date"

dragonwell_extended8_image="$dockerhub_repo:v10-sp2-amd64-dragonwell-extended8-$build_date"
dragonwell_extended11_image="$dockerhub_repo:v10-sp2-amd64-dragonwell-extended11-$build_date"
dragonwell_extended21_image="$dockerhub_repo:v10-sp2-amd64-dragonwell-extended21-$build_date"

dragonwell_extended8_maven3_9_image="$dockerhub_repo:v10-sp2-amd64-dragonwell-extended8-maven3.9-$build_date"
dragonwell_extended11_maven3_9_image="$dockerhub_repo:v10-sp2-amd64-dragonwell-extended11-maven3.9-$build_date"
dragonwell_extended21_maven3_9_image="$dockerhub_repo:v10-sp2-amd64-dragonwell-extended21-maven3.9-$build_date"

oraclejdk8u202_image="$dockerhub_repo:v10-sp2-amd64-oraclejdk8u202-$build_date"

oraclejdk8u202_maven3_9_image="$dockerhub_repo:v10-sp2-amd64-oraclejdk8u202-maven3.9-$build_date"

pyenv_image="$dockerhub_repo:v10-sp2-amd64-pyenv-$build_date"

pyenv_oracle_image="$dockerhub_repo:v10-sp2-amd64-pyenv-oracle-$build_date"

tomcat9_image="$dockerhub_repo:v10-sp2-amd64-dragonwell-extended11-tomcat9-$build_date"

nginx_image="$dockerhub_repo:v10-sp2-amd64-nginx-$build_date"

nvm_image="$dockerhub_repo:v10-sp2-amd64-nvm-$build_date"

all_tools_image="$dockerhub_repo:v10-sp2-amd64-all-tools-$build_date"
