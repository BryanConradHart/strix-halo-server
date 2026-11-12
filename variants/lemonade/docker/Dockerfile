# docker image that allows running lemonade in a docker container, 
# giving it access to podman so it can use containerized engines
FROM ghcr.io/lemonade-sdk/lemonade-server:edge

USER root

# Install podman and runtime dependencies (crun, netavark, fuse-overlayfs, etc.)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      podman crun fuse-overlayfs passt slirp4netns uidmap && \
    rm -rf /var/lib/apt/lists/*

# Configure nested Podman storage and container drivers
RUN id -u 10001 >/dev/null 2>&1 || useradd -u 10001 -m -d /opt/lemonade -s /bin/bash lemonade && \
    echo "10001:100000:65536" > /etc/subuid && \
    echo "10001:100000:65536" > /etc/subgid && \
    mkdir -p /etc/containers /opt/lemonade/.local/share/containers /var/lib/lemonade/huggingface && \
    printf '[storage]\ndriver = "overlay"\n[storage.options.overlay]\nmount_program = "/usr/bin/fuse-overlayfs"\n' > /etc/containers/storage.conf && \
    printf '[engine]\ncgroup_manager = "cgroupfs"\nevents_logger = "file"\n' > /etc/containers/containers.conf && \
    chown -R 10001:10001 /opt/lemonade /var/lib/lemonade/huggingface

USER 10001
