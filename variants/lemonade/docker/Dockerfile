# docker image that allows running lemonade in a docker container, 
# giving it access to podman so it can use containerized engines
FROM ghcr.io/lemonade-sdk/lemonade-server

USER root

# Install podman and runtime dependencies (crun, netavark, fuse-overlayfs, etc.)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      podman crun catatonit fuse-overlayfs netavark aardvark-dns passt slirp4netns uidmap && \
    rm -rf /var/lib/apt/lists/*


# Configure nested Podman storage and container drivers
RUN id -u lemonade >/dev/null 2>&1 || useradd -u 10001 -m -d /opt/lemonade -s /bin/bash lemonade && \
    echo "lemonade:100000:65536" > /etc/subuid && \
    echo "lemonade:100000:65536" > /etc/subgid && \

    mkdir -p /etc/containers /run/netns /opt/lemonade/.local/share/containers /var/lib/lemonade/huggingface && \
    printf '[storage]\ndriver = "overlay"\n[storage.options.overlay]\nmount_program = "/usr/bin/fuse-overlayfs"\n' > /etc/containers/storage.conf && \
    printf '[engine]\ncgroup_manager = "cgroupfs"\nevents_logger = "file"\n' > /etc/containers/containers.conf && \
    chown -R 10001:10001 /opt/lemonade /var/lib/lemonade/huggingface

USER 10001
