# =============================================================================
# Lemonade Server + nested Podman (containerized engines)
# =============================================================================
# Extends the official ghcr.io/lemonade-sdk/lemonade-server image so that
# Lemonade's *containerized engines* (e.g. the vLLM engine) work inside a
# Docker container. The upstream image and its Docker deployment docs
# (docs/guide/install/docker.md) only cover running lemond itself; engines
# that ship as OCI images need a full container runtime (podman), subuid/
# subgid ranges, and a storage/network stack that works unprivileged inside
# a container. Everything deployment-agnostic is baked in here so a compose
# file can stay close to the documented one:
#
#   * podman + crun + catatonit + fuse-overlayfs + netavark + aardvark-dns
#     + passt + slirp4netns + uidmap + iptables + iproute2
#   * subuid/subgid allocation for the lemonade user (UID 10001)
#   * /etc/containers/storage.conf    (overlay via fuse-overlayfs)
#   * /etc/containers/containers.conf (cgroupfs, file events, netavark,
#                                      unlimited memlock for nested engines)
#   * LEMONADE_DEFAULTS_PATH          (system defaults file location)
#   * HF_HOME                         (HuggingFace cache location)
#   * XDG_RUNTIME_DIR                 (per-UID runtime dir under /tmp, which
#                                      survives like a tmpfs across restarts)
#   * HOME=/opt/lemonade              (kept explicit; upstream sets it too)
#
# What CANNOT be baked into any image and must stay in the compose file /
# `docker run` invocation (this is the gap being demonstrated):
#
#   * --device /dev/kfd, /dev/dri           (ROCm GPU passthrough)
#   * --group-add 39 (video) / render GID  (numeric GIDs, host-dependent;
#     e.g. 39 for video on Fedora CoreOS)
#   * SYS_ADMIN, MKNOD, NET_ADMIN, SETUID, SETGID capabilities
#     (podman-in-docker: mounts, device nodes, container networking)
#   * seccomp=unconfined, label=disable, unmask=/proc/*
#     (ROCm/ioctl + SELinux + /proc access needed by nested runtimes)
#   * ulimits memlock -1                    (GPU pinned memory)
#   * named volumes, env_file, and the deployment defaults.json content
#     (allowed origins, max loaded models, API keys, etc.)
#
# Build:  docker build -t <your-registry>/lemonade-server-podman:latest .
# =============================================================================
FROM ghcr.io/lemonade-sdk/lemonade-server

USER root

# Podman and the runtime dependencies needed to run containers inside this
# container (nested rootless podman): engine, pause/init binary, unprivileged
# overlay mounts, network stack, port forwarding, and id mapping.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      podman crun catatonit fuse-overlayfs netavark aardvark-dns passt slirp4netns uidmap iptables iproute2 && \
    rm -rf /var/lib/apt/lists/*

# Rootless-podman prerequisites for the lemonade user + container storage and
# engine configuration that works when there is no cgroup v2 delegation and no
# /dev/fuse-backed kernel overlay available to the nested runtime.
RUN id -u lemonade >/dev/null 2>&1 || useradd -u 10001 -m -d /opt/lemonade -s /bin/bash lemonade && \
    echo "lemonade:100000:65536" > /etc/subuid && \
    echo "lemonade:100000:65536" > /etc/subgid && \
    mkdir -p /etc/containers /run/netns \
             /opt/lemonade/.local/share/containers \
             /opt/lemonade/.config/lemonade \
             /opt/lemonade/.cache/lemonade \
             /var/lib/lemonade/huggingface \
             /etc/lemonade \
             /tmp/runtime-10001 && \
    printf '[storage]\ndriver = "overlay"\n[storage.options.overlay]\nmount_program = "/usr/bin/fuse-overlayfs"\n' > /etc/containers/storage.conf && \
    printf '[engine]\n cgroup_manager = "cgroupfs"\n events_logger = "file"\n default_ulimits = ["memlock=-1:-1"]\n[network]\n network_backend = "netavark"\n' > /etc/containers/containers.conf && \
    chown -R 10001:10001 /opt/lemonade /var/lib/lemonade && \
    chown 10001:10001 /tmp/runtime-10001 && chmod 700 /tmp/runtime-10001

# Deployment-agnostic environment: where lemond finds its system defaults
# file (mount/bake the JSON at this path) and where model downloads land.
# XDG_RUNTIME_DIR is set explicitly because the upstream /run/lemonade dir is
# created at build time but not guaranteed writable/recreated at container
# start, and nested podman also wants a per-UID runtime directory.
ENV HOME=/opt/lemonade \
    LEMONADE_DEFAULTS_PATH=/etc/lemonade/defaults.json \
    HF_HOME=/var/lib/lemonade/huggingface \
    XDG_RUNTIME_DIR=/tmp/runtime-10001

USER 10001

EXPOSE 13305
CMD ["./lemond", "--host", "0.0.0.0"]
