#checkov:skip=CKV2_DOCKER_1: we need sudo
# don't warn on not pinning apt-get installs
# hadolint global ignore=DL3008

FROM ubuntu:24.04 AS cli

RUN DEBIAN_FRONTEND=noninteractive TZ=Europe/Berlin apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        sudo \
        tzdata \
    && rm -rf /var/lib/apt/lists/*

RUN echo "ubuntu ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ubuntu
USER ubuntu

FROM cli AS desktop

USER root
RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && apt-get install -y --no-install-recommends \
        ubuntu-desktop-minimal \
    && rm -rf /var/lib/apt/lists/*

USER ubuntu
RUN mkdir /home/ubuntu/Bilder
