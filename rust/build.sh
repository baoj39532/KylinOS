#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "$script_dir/../common.sh"

docker build "$script_dir" \
    --platform linux/arm64 \
    --build-arg BASE_IMAGE="$arm64_os_image" \
    --no-cache \
    -f "$script_dir/kylin-V10SP2.rust1.98.1.Dockerfile" \
    -t "$arm64_rust1_98_1_image"

docker run --rm --platform linux/arm64 "$arm64_rust1_98_1_image" /bin/bash -euxo pipefail -c '
    test "$(uname -m)" = "aarch64"
    rustc --version | grep -q "^rustc 1\.98\.1 "
    rustc -vV | grep -qx "host: aarch64-unknown-linux-gnu"
    cargo --version
    rustfmt --version
    cargo clippy --version
    printf "fn main() { println!(\"rust-arm64-ok\"); }\n" > /tmp/main.rs
    rustc /tmp/main.rs -o /tmp/rust-arm64-smoke
    /tmp/rust-arm64-smoke | grep -qx "rust-arm64-ok"
'

docker push "$arm64_rust1_98_1_image"
