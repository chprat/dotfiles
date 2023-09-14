FROM debian:bookworm-slim
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Berlin

# install required tools
RUN apt-get update && apt-get install --no-install-recommends -y \
    locales \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# generate locale
RUN sed -i '/en_US.UTF-8/s/^#//g' /etc/locale.gen && locale-gen \
    && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8

WORKDIR /code
ENTRYPOINT [ "/code/lint.sh" ]
