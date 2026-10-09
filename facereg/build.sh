#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "$script_dir/../common.sh"

docker build "$script_dir" \
    --platform linux/arm64 \
    --build-arg BASE_IMAGE="$arm64_os_image" \
    --no-cache \
    -f "$script_dir/kylin-V10SP2.facereg-base.Dockerfile" \
    -t "$arm64_facereg_base_image"

docker run --rm --platform linux/arm64 "$arm64_facereg_base_image" /bin/bash -euxo pipefail -c '
    test "$(uname -m)" = "aarch64"
    test "$(python -c "import platform; print(platform.python_version())")" = "3.12.12"
    test "$(/opt/venv/bin/python -c "import platform; print(platform.python_version())")" = "3.12.12"
    test "$(/usr/local/pyenv/versions/3.12.12/bin/python -c "import platform; print(platform.python_version())")" = "3.12.12"
    python -c "import ssl, sqlite3, bz2, readline, ctypes"
    python -m pip --version
    gcc --version
    pg_config --version
    rpm -q \
        gcc \
        postgresql-devel \
        postgresql-libs \
        mesa-libGL \
        glib2 \
        curl \
        tzdata \
        shadow
    getent group appgroup
    id appuser
    test "$PYTHONDONTWRITEBYTECODE" = "1"
    test "$PYTHONUNBUFFERED" = "1"
    test "$APP_HOME" = "/app"
    test "$HOME" = "/app"
    test "$INSIGHTFACE_MODELS_DIR" = "/app/models"
    test "$OPENCV_IO_ENABLE_OPENGL" = "0"
    test "$QT_QPA_PLATFORM" = "offscreen"
    test "$PWD" = "/app"
'

docker push "$arm64_facereg_base_image"
