# Strix Halo Server

Preconfigured lightweight bootc-based Linux images for AMD Strix Halo systems, published to GHCR.

## Available images

| Variant | Image | Description |
| --- | --- | --- |
| [Base](variants/base/README.md) | `ghcr.io/bryanconradhart/strix-halo-server` | Clean Strix Halo platform based on [uCore](https://github.com/ublue-os/ucore), with shared hardware configuration, Mesa Vulkan drivers, and hardware inspection tools. |
| [Arcane Manager](variants/arcane-manager/README.md) | `ghcr.io/bryanconradhart/strix-halo-server-arcane-manager` | The base platform plus [Arcane](https://github.com/getarcaneapp/arcane) for administering local and remote container environments. |
| [Arcane Edge Agent](variants/arcane-agent-edge/README.md) | `ghcr.io/bryanconradhart/strix-halo-server-arcane-agent-edge` | The base platform plus the [Arcane Edge Agent](https://github.com/getarcaneapp/arcane) for hosts that connect outbound to Arcane Manager. |
| [Arcane Direct Agent](variants/arcane-manager-direct/README.md) | `ghcr.io/bryanconradhart/strix-halo-server-arcane-manager-direct` | The base platform plus the [Arcane Direct Agent](https://github.com/getarcaneapp/arcane), configured to connect to an Arcane Manager. |
| [AI Toolbox Cockpit](variants/ai-toolbox-cockpit/README.md) | `ghcr.io/bryanconradhart/strix-halo-server-ai-toolbox-cockpit` | The base platform plus [AI Toolbox Cockpit](https://github.com/kyuz0/ai-toolbox-cockpit) for managing AI toolboxes, models, and inference servers. |
| [Lemonade Server](variants/lemonade/README.md) | `ghcr.io/bryanconradhart/strix-halo-server-lemonade` | The base platform plus [Lemonade Server](https://github.com/lemonade-sdk/lemonade) for local AI APIs with AMD GPU support. |

## Install

Choose a variant from the table and copy its image reference. Use that image in one of the following options. After installation, visit the variant's README for any first-boot prompts and application-specific setup.

### Before you begin: Secure Boot

If Secure Boot is enabled, the Universal Blue signing key must be enrolled, regardless of installation method. Existing uCore users can verify enrollment:

```bash
sudo mokutil --sb-state
sudo mokutil --test-key /etc/pki/akmods/certs/akmods-ublue.der
```

If it is not enrolled, follow uCore's [Secure Boot guide](https://projectucore.org/docs/secure-boot/). For a clean install, temporarily disable Secure Boot, install and boot the image, enroll the key at the machine's console, then re-enable Secure Boot. See uCore's [first-install guide](https://projectucore.org/docs/first-install/#before-you-begin).

### 1. Switch an existing bootc system

On a system managed by bootc, replace `IMAGE_FROM_TABLE` with the image from the table, then switch and reboot:

```bash
sudo bootc switch --transport registry IMAGE_FROM_TABLE:latest
sudo systemctl reboot
```

Check that the current system is bootc-managed with `sudo bootc status`. If you do not already have a bootc-managed system, use one of the clean-install options below and follow the chosen variant's README after installation.

### 2. Clean install from a Linux live USB

Boot the target computer from a [Fedora Workstation live USB](https://fedoraproject.org/workstation/download/). In its terminal, install Podman if needed and use `lsblk` to identify the whole target disk:

```bash
sudo dnf install -y podman
lsblk -o NAME,PATH,SIZE,MODEL,TYPE,MOUNTPOINTS
```

Replace `IMAGE_FROM_TABLE` with the selected image and `/dev/nvme0n1` with the whole-disk device (not a partition), then run:

```bash
sudo podman run --rm --privileged --pid=host --ipc=host \
  -v /var/lib/containers:/var/lib/containers \
  -v /dev:/dev \
  --security-opt label=type:unconfined_t \
  IMAGE_FROM_TABLE:latest \
  bootc install to-disk /dev/nvme0n1
```

The live USB also appears in the `lsblk` output. **This erases the target disk, including all existing data.** Verify the device path carefully before running the command. After it completes, shut down, remove the live USB, and boot from the installed disk.

### 3. Install from a locally built ISO

Use the [BlueBuild CLI ISO instructions](https://blue-build.org/how-to/generate-iso/) to build an ISO from the selected image:

```bash
sudo bluebuild generate-iso \
  --iso-name strix-halo.iso \
  --platform linux/amd64 \
  image IMAGE_FROM_TABLE:latest
```

Replace `IMAGE_FROM_TABLE` with the selected image. Write the resulting `strix-halo.iso` to a USB drive using `dd` or a graphical flashing tool such as balenaEtcher or Rufus.

For `dd`:
```bash
sudo dd if=./strix-halo.iso of=/dev/sdX bs=4M status=progress conv=fsync
```

Replace `/dev/sdX` with the USB device (not a partition); writing the ISO erases that device. Boot the target computer from the USB drive and follow the installer's on-screen steps to install the image to the system disk.

## Project goals

This project provides a lightweight, reproducible platform for Strix Halo systems, especially for local AI, inference, development, and self-hosted compute. Optional variants make common additions straightforward while keeping workload toolchains and custom services out of the clean base image.

For custom images, start from the published variant closest to your use case, add only the required packages and configuration, and publish it under your own image name.
