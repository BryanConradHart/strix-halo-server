# docker image that allows running lemonade in a docker container, 
# giving it access to podman so it can use containerized engines
FROM ghcr.io/lemonade-sdk/lemonade-server:edge

USER root

# Install native podman client with its required Ubuntu shared libraries
RUN apt-get update && \
    apt-get install -y --no-install-recommends podman && \
    rm -rf /var/lib/apt/lists/*

# Point Podman's client library to the mounted host socket
ENV CONTAINER_HOST=unix:///run/podman/podman.sock

# Return to Lemonade's unprivileged runtime user
USER 10001
