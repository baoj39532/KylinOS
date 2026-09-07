#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "$script_dir/../common.sh"

docker build "$script_dir" \
    --platform linux/arm64 \
    --no-cache \
    -f "$script_dir/kylin-V10SP2.os.Dockerfile" \
    -t "$arm64_os_image"

docker run --rm --platform linux/arm64 "$arm64_os_image" /bin/bash -euxc '
    test "$(uname -m)" = "aarch64"
    rpm -q kylin-release
    test "$(rpm --eval "%{_arch}")" = "aarch64"
'

docker push "$arm64_os_image"
