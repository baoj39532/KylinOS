# syntax=docker/dockerfile:1

ARG BASE_IMAGE

FROM ${BASE_IMAGE}

ENV PYENV_ROOT=/pyenv
ENV PATH=$PATH:$PYENV_ROOT/bin:$PYENV_ROOT/shims

RUN yum install git vim patch make gcc gcc-c++ zlib-devel libffi-devel openssl-devel bzip2-devel readline-devel sqlite-devel xz-devel -y && curl -sSL https://pyenv.run | bash

RUN pyenv install 3.6.8 && pyenv install 3.8.20 && pyenv install 3.9.25 && pyenv install 3.10.19 && pyenv install 3.11.14 && pyenv install 3.12.12 && pyenv install 3.13.9 && pyenv install 3.14.0

# Initialize pyenv to create shims directory, then fix permissions for non-root users
RUN eval "$(pyenv init -)" && pyenv rehash || true
# Make /pyenv readable and executable by all users
RUN chmod -R a+rx /pyenv
# Make /pyenv/shims writable by all users (needed for pyenv rehash and shim creation)
RUN mkdir -p /pyenv/shims && chmod -R a+w /pyenv/shims

ENV PYENV_VERSION=3.12
RUN eval "$(pyenv init -)"
