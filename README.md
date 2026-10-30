# Strix Halo Server

A bootc-based Linux image for AMD Strix Halo systems, published to GHCR for installation and updates.

## Image contents

- Based on uCore, with Strix Halo kernel settings for GPU memory sizing and IOMMU passthrough, targeting 128 GB systems.
- Includes Mesa Vulkan drivers, `clinfo` and `rocminfo` hardware inspection tools, and `tuned`.
- Keeps AI frameworks, inference servers, and other workload-specific software optional, so you can add only what you need in a derived image.

## Install the image

Choose the option that matches your starting point. All three options need an internet connection to pull the image.

### 1. On a system that already has bootc

On a system managed by bootc, run `bootc switch` and reboot:

```bash
sudo bootc switch --transport registry ghcr.io/bryanconradhart/strix-halo-server:latest
sudo systemctl reboot
```

Check whether your current system is bootc-managed with `sudo bootc status`. For uCore installations managed with rpm-ostree, follow the [uCore transition guidance](https://projectucore.org/docs/rebasing/).

For a repeatable deployment, replace `latest` with a versioned tag listed on the [published container image page](https://github.com/BryanConradHart/strix-halo-server/pkgs/container/strix-halo-server).

### 2. From a live USB using a temporary Linux system

Boot the target computer from a [Fedora Workstation live USB](https://fedoraproject.org/workstation/download/). This provides a temporary Linux system to run the installer without first installing an operating system. In its terminal, install Podman if needed, then run the image's bootc installer:

```bash
sudo dnf install -y podman
lsblk -o NAME,PATH,SIZE,MODEL,TYPE,MOUNTPOINTS

sudo podman run --rm --privileged --pid=host --ipc=host \
  -v /var/lib/containers:/var/lib/containers \
  -v /dev:/dev \
  --security-opt label=type:unconfined_t \
  ghcr.io/bryanconradhart/strix-halo-server:latest \
  bootc install to-disk /dev/nvme0n1
```

The command assumes the target is the first NVMe disk (`/dev/nvme0n1`), a common setup. If your target disk is different, use the `lsblk` output to identify it by size and model, then replace the device path in the command with the whole-disk device (not a partition). The live USB also appears in the list. **This erases the target disk, including all existing data.** Verify the device carefully before running the command. After it completes, shut down, remove the live USB, and boot from the installed disk. The new system will use the published image for future bootc updates.

### 3. By building an installable ISO

Build an ISO locally from our published image with the [BlueBuild CLI](https://blue-build.org/how-to/generate-iso/). Choose one way to run it:

Install the CLI following its [installation instructions](https://blue-build.org/), then run:

```bash
sudo bluebuild generate-iso \
  --iso-name strix-halo.iso \
  --platform linux/amd64 \
  image ghcr.io/bryanconradhart/strix-halo-server:latest
```

Or run it in Docker. The container needs `--privileged` to run the ISO builder; the current directory is mounted so the ISO is saved there.

```bash
docker run --rm --privileged \
  -v "$PWD:/bluebuild" \
  -w /bluebuild \
  ghcr.io/blue-build/cli:latest \
  bluebuild generate-iso \
  --run-driver podman \
  --iso-name strix-halo.iso \
  --platform linux/amd64 \
  image ghcr.io/bryanconradhart/strix-halo-server:latest
```

Or use Podman:

```bash
podman run --rm --privileged \
  -v "$PWD:/bluebuild" \
  -w /bluebuild \
  ghcr.io/blue-build/cli:latest \
  bluebuild generate-iso \
  --run-driver podman \
  --iso-name strix-halo.iso \
  --platform linux/amd64 \
  image ghcr.io/bryanconradhart/strix-halo-server:latest
```

Each command creates `strix-halo.iso` in the current directory. Replace `latest` with a versioned tag from the [published container image page](https://github.com/BryanConradHart/strix-halo-server/pkgs/container/strix-halo-server) to build from a specific image. Write the ISO to a USB drive using `dd` or a graphical flashing tool such as balenaEtcher or Rufus. For `dd`:

```bash
sudo dd if=./strix-halo.iso of=/dev/sdX bs=4M status=progress conv=fsync
```

Replace `/dev/sdX` with the USB device (not a partition); writing the image erases that device. Boot the target computer from the USB drive and follow the installer's on-screen steps to install the image to the system disk.

## Managing upgrades after installation

After installation, upgrades are handled through bootc.

Check the current image state:

```bash
sudo bootc status
```

Upgrade to the newest published build:

```bash
sudo bootc upgrade
```

Or switch directly to a specific image tag:

```bash
sudo bootc switch --transport registry ghcr.io/bryanconradhart/strix-halo-server:latest
```

or a pinned version:

```bash
sudo bootc switch --transport registry ghcr.io/bryanconradhart/strix-halo-server:v2026.10.30-153015-r123
```

Then reboot to apply the new image:

```bash
sudo reboot
```

## Image tags

The repository publishes:
- `latest`: newest build
- versioned tags in the form `vYYYY.MM.DD-HHMMSS-rRUN_NUMBER`: exact image builds

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
