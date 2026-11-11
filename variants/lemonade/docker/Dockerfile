# docker image that allows running lemonade in a docker container, 
# giving it access to podman so it can use containerized engines
FROM ghcr.io/lemonade-sdk/lemonade-server:edge

LABEL org.opencontainers.image.title="Lemonade Server (with containerized engine support)" \
      org.opencontainers.image.description="Application container wrapping lemonade-server with Podman CLI support for running containerized engines, in something like arcane" \
      org.opencontainers.image.source="https://github.com" \
      org.opencontainers.image.licenses="MIT"

USER root

# Install native podman client with its required Ubuntu shared libraries
RUN apt-get update && \
    apt-get install -y --no-install-recommends podman && \
    rm -rf /var/lib/apt/lists/*

# Point Podman's client library to the mounted host socket
ENV CONTAINER_HOST=unix:///run/podman/podman.sock

# Return to Lemonade's unprivileged runtime user
USER 10001
