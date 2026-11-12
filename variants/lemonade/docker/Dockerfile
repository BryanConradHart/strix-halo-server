# docker image that allows running lemonade in a docker container, 
# giving it access to podman so it can use containerized engines
FROM ghcr.io/lemonade-sdk/lemonade-server:edge

USER root

# Install podman and runtime dependencies (crun, netavark, fuse-overlayfs, etc.)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      podman crun fuse-overlayfs slirp4netns uidmap && \
    rm -rf /var/lib/apt/lists/*

# Configure nested Podman storage and container drivers
RUN mkdir -p /etc/containers && \
    printf '[storage]\ndriver = "overlay"\nrunroot = "/run/containers/storage"\ngraphroot = "/var/lib/containers/storage"\n[storage.options.overlay]\nmount_program = "/usr/bin/fuse-overlayfs"\n' > /etc/containers/storage.conf && \
    printf '[engine]\ncgroup_manager = "cgroupfs"\nevents_logger = "file"\n' > /etc/containers/containers.conf

USER 10001
