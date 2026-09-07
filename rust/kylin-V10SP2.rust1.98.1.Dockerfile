# syntax=docker/dockerfile:1
# check=skip=InvalidDefaultArgInFrom

ARG BASE_IMAGE

FROM ${BASE_IMAGE}

ARG TARGETARCH
ARG RUST_VERSION=1.98.1

RUN test "$TARGETARCH" = "arm64"

RUN yum install -y \
        gcc \
        gcc-c++ \
        make \
        cmake \
        git \
        pkgconf \
        openssl-devel \
    && yum clean all \
    && rm -rf /var/cache/yum

ENV RUSTUP_HOME=/usr/local/rustup
ENV CARGO_HOME=/usr/local/cargo
ENV PATH=$CARGO_HOME/bin:$PATH

RUN curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs -o /tmp/rustup-init.sh \
    && sh /tmp/rustup-init.sh \
        -y \
        --no-modify-path \
        --profile minimal \
        --default-toolchain "$RUST_VERSION" \
    && rm -f /tmp/rustup-init.sh \
    && rustup component add rustfmt clippy \
    && rustc --version > /tmp/rustc-version \
    && grep -q '^rustc 1\.98\.1 ' /tmp/rustc-version \
    && rustc -vV > /tmp/rustc-verbose \
    && grep -qx 'host: aarch64-unknown-linux-gnu' /tmp/rustc-verbose \
    && rm -f /tmp/rustc-version /tmp/rustc-verbose \
    && cargo --version \
    && rustfmt --version \
    && cargo clippy --version

CMD ["/bin/bash"]
