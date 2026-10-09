# syntax=docker/dockerfile:1
# check=skip=InvalidDefaultArgInFrom

ARG BASE_IMAGE

FROM ${BASE_IMAGE}

ARG TARGETARCH
ARG PYTHON_VERSION=3.12.12

RUN test "$TARGETARCH" = "arm64"

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    APP_HOME=/app \
    HOME=/app \
    PYENV_ROOT=/usr/local/pyenv \
    INSIGHTFACE_MODELS_DIR=/app/models \
    OPENCV_IO_ENABLE_OPENGL=0 \
    QT_QPA_PLATFORM=offscreen
ENV PATH="/opt/venv/bin:${PYENV_ROOT}/bin:${PYENV_ROOT}/shims:${PATH}"

WORKDIR ${APP_HOME}

RUN yum install -y \
        git \
        patch \
        make \
        gcc \
        zlib-devel \
        libffi-devel \
        openssl-devel \
        bzip2-devel \
        readline-devel \
        sqlite-devel \
        xz-devel \
        postgresql-devel \
        postgresql-libs \
        mesa-libGL \
        glib2 \
        curl \
        tzdata \
        shadow \
    && yum clean all \
    && rm -rf /var/cache/yum

RUN curl -fsSL https://pyenv.run -o /tmp/pyenv-installer \
    && bash /tmp/pyenv-installer \
    && rm -f /tmp/pyenv-installer \
    && pyenv install "$PYTHON_VERSION" \
    && pyenv global "$PYTHON_VERSION" \
    && pyenv rehash \
    && python -m venv /opt/venv \
    && groupadd -r appgroup \
    && useradd -r -g appgroup appuser \
    && python --version \
    && /opt/venv/bin/python --version

CMD ["/bin/bash"]
