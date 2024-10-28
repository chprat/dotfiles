# hadolint global ignore=DL3027,SC1091
FROM ubuntu:24.04
ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
    curl \
    lua-check \
    python3-venv \
    shellcheck \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN HADOLINT_VERSION=$(curl -s "https://api.github.com/repos/hadolint/hadolint/releases/latest" | grep -Po '"tag_name": "\K[^"]*') \
    && export HADOLINT_VERSION \
    && curl -Lo "$HOME/hadolint" "https://github.com/hadolint/hadolint/releases/download/$HADOLINT_VERSION/hadolint-Linux-x86_64" \
    && chmod +x "$HOME/hadolint"

RUN python3 -m venv --upgrade-deps "$HOME/linter-venv" \
    && . "$HOME/linter-venv/bin/activate" \
    && python3 -m pip install --no-cache-dir \
    editorconfig-checker \
    && deactivate

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN ACTIONLINT_VERSION=$(curl -s "https://api.github.com/repos/rhysd/actionlint/releases/latest" | grep -Po '"tag_name": "v\K[^"]*') \
    && export ACTIONLINT_VERSION \
    && curl -Lo "$HOME/actionlint.tar.gz" "https://github.com/rhysd/actionlint/releases/download/v$ACTIONLINT_VERSION/actionlint_${ACTIONLINT_VERSION}_linux_amd64.tar.gz" \
    && tar xf "$HOME/actionlint.tar.gz" -C "$HOME" actionlint \
    && rm "$HOME/actionlint.tar.gz"
