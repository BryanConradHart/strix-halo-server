# Strix Halo Server

A lightweight, bootable container image designed for AMD Strix Halo systems, with emphasis on high-performance local AI workloads, low-drift system maintenance, and practical self-hosted server use.

This project provides a reproducible base image that boots cleanly on Strix Halo hardware, stays current with upstream updates, and is easy to rebuild and maintain using an immutable, bootc-based workflow.

## What this project provides

- a bootable ISO for installing the system to bare metal
- a container image published to GHCR for bootc-based installation and updates
- a lightweight Linux base tuned for local AI and dev workloads on Strix Halo systems
- a system that is easy to rebuild, update, and extend with workload-specific components

## Quick start

Choose the installation method that matches your setup:

- ISO install: best for clean bare-metal installation
- bootc install: best for an existing system or for update-driven deployment

## Install from the ISO

Download the latest ISO from the GitHub Releases page for this repository.

1. Open the Releases page for this repository.
2. Download the latest available ISO asset.
3. Write it to a USB drive or bootable media.

On Linux:

```bash
sudo dd if=path/to/strix-halo-server.iso of=/dev/sdX bs=4M status=progress conv=fsync
```

On macOS or Windows, use a tool such as balenaEtcher or Rufus.

Then:

1. Boot the target machine from the USB drive.
2. Select the installer or live environment from the boot menu.
3. Follow the on-screen installation flow to install the image to disk.
4. Reboot into the installed system.

## Install with bootc

This repository also publishes a bootc-compatible container image to GHCR. This is the recommended path if you want to install or update from a container-native workflow.

### Pull the image

```bash
docker pull ghcr.io/bryanconradhart/strix-halo-server:latest
```

or:

```bash
podman pull ghcr.io/bryanconradhart/strix-halo-server:latest
```

### Install to a local filesystem

For an existing Linux system, you can install the image into the target root filesystem using bootc.

```bash
sudo bootc install to-filesystem --root-ssh-key ~/.ssh/id_ed25519.pub /dev/nvme0n1
```

If you are installing to a different disk or partition, replace `/dev/nvme0n1` with the correct target device.

### Switch the system to the image

After installation, point the running system at the published image:

```bash
sudo bootc switch --transport registry ghcr.io/bryanconradhart/strix-halo-server:latest
```

Then reboot to apply the image.

```bash
sudo reboot
```

### Upgrade later

To update to the newest build:

```bash
sudo bootc upgrade
```

Or switch directly to a specific tagged build:

```bash
sudo bootc switch --transport registry ghcr.io/bryanconradhart/strix-halo-server:v2026.10.30-153015-r123
```

## Image tags

The repository publishes:

- `latest`: newest build
- versioned tags in the form `vYYYY.MM.DD-HHMMSS-rRUN_NUMBER`: exact release builds
- release assets for ISO downloads on the GitHub Releases page

This gives you both:

- a stable, versioned reference for reproducible installs
- a ready-to-use `latest` image for routine upgrades

## Extend this image with your own bootc details

This project is intended to be a base image you can customize for your own workloads. The bootc model is particularly good for this because the image is built as a container, then applied as a system image.

### Recommended approach

Create your own container image that starts from this project’s image, then add:

- your packages
- your configs
- your SSH setup
- your service definitions
- your local AI toolchain
- your custom system settings

Example:

```dockerfile
FROM ghcr.io/bryanconradhart/strix-halo-server:latest

RUN dnf install -y \
    python3 \
    git \
    curl \
    jq

COPY files/sshd_config /etc/ssh/sshd_config
COPY files/custom.conf /etc/myapp/custom.conf

RUN systemctl enable sshd
```

Then build it:

```bash
podman build -t ghcr.io/your-user/strix-halo-custom:latest .
```

Push it:

```bash
podman push ghcr.io/your-user/strix-halo-custom:latest
```

Then switch your installed system to it:

```bash
sudo bootc switch --transport registry ghcr.io/your-user/strix-halo-custom:latest
```

Reboot:

```bash
sudo reboot
```

### Put system configuration in the image

If you want custom behavior baked directly into the installed system, add it to the container image instead of doing ad-hoc tweaks on the host. Good things to put in the image include:

- systemd service files
- `/etc` configuration
- user/group setup
- hostnames
- package installs
- local startup scripts

For example:

```dockerfile
FROM ghcr.io/bryanconradhart/strix-halo-server:latest

COPY files/hostname /etc/hostname
COPY files/80-local-setup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/80-local-setup.sh
RUN ln -sf /usr/local/bin/80-local-setup.sh /etc/profile.d/
```

### Keep the base image stable and custom layers clean

A good pattern is:

- keep the upstream Strix Halo image as the base
- add only your own required customizations
- version your own image separately
- use `latest` for active development
- use versioned tags for reproducible deployments

Example:

```bash
podman build -t ghcr.io/your-user/strix-halo-custom:v1.0.0 .
podman push ghcr.io/your-user/strix-halo-custom:v1.0.0
```

Then install or switch specifically to that version:

```bash
sudo bootc switch --transport registry ghcr.io/your-user/strix-halo-custom:v1.0.0
```

### When to use the ISO vs the bootc image

Use the ISO when:
- you are doing a clean install on bare metal
- you want a fresh system booted from media
- you want a standard installation flow with no existing OS

Use bootc when:
- you already have a Linux system
- you want to update in place
- you want to make a custom image and deploy it repeatedly
- you want container-native image upgrades

## Why this design

This project is intended to serve as a base platform for Strix Halo hardware, especially for local AI, inference, and self-hosted compute workloads. The goal is to keep the base image clean, predictable, and easy to rebuild without drifting into a messy mutable setup.

## Repository goals

This repository is a starting point for a Strix Halo-focused bootable image built around a lightweight, container-first approach. It aims to keep the base image clean, reproducible, and easy to extend for specialized workloads such as:

- AI toolchains and inference workloads
- local model serving
- remote orchestration and management tooling
- custom edge or lab deployments
- repeatable bare-metal installations

## License

This project is released under the terms of the repository license, if one is present. Check the repository root for the exact license file before redistribution or commercial use.
