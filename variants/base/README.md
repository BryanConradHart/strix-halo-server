# Strix Halo Server (Base)

The clean Strix Halo image. It includes the shared 128 GB Strix hardware configuration, Mesa Vulkan drivers, `clinfo`, `rocminfo`, and the tuned performance profile setup. It does not include workload-specific software or the Arcane Agent.

Image: `ghcr.io/bryanconradhart/strix-halo-server`

## Install

Choose the option that matches your starting point. Each option needs an internet connection to pull the image.

### 1. On a system that already has bootc

On a system managed by bootc, switch to this image and reboot:

```bash
sudo bootc switch --transport registry ghcr.io/bryanconradhart/strix-halo-server:latest
sudo systemctl reboot
```

Check whether your current system is bootc-managed with `sudo bootc status`. For uCore installations managed with rpm-ostree, follow the [uCore transition guidance](https://projectucore.org/docs/rebasing/).

### 2. From a live USB using a temporary Linux system

Boot the target computer from a [Fedora Workstation live USB](https://fedoraproject.org/workstation/download/). In its terminal, install Podman if needed, identify the target disk, then run the image's bootc installer:

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

Replace `/dev/nvme0n1` with the whole-disk device identified using `lsblk` (not a partition). The live USB also appears in the list. **This erases the target disk, including all existing data.** Verify the device carefully before running the command. After it completes, shut down, remove the live USB, and boot from the installed disk.

### 3. By building an installable ISO

Use the [BlueBuild CLI](https://blue-build.org/how-to/generate-iso/) to build an ISO from this image:

```bash
sudo bluebuild generate-iso \
  --iso-name strix-halo.iso \
  --platform linux/amd64 \
  image ghcr.io/bryanconradhart/strix-halo-server:latest
```

Write the ISO to a USB drive using `dd` or a graphical flashing tool such as balenaEtcher or Rufus. For `dd`:

```bash
sudo dd if=./strix-halo.iso of=/dev/sdX bs=4M status=progress conv=fsync
```

Replace `/dev/sdX` with the USB device (not a partition); writing the image erases that device. Boot the target computer from the USB drive and follow the installer's on-screen steps to install the image to the system disk.

## Updates

After installation, upgrades are handled through bootc. Check the current image state and upgrade to the newest build:

```bash
sudo bootc status
sudo bootc upgrade
sudo systemctl reboot
```

To switch directly to a specific image tag:

```bash
sudo bootc switch --transport registry ghcr.io/bryanconradhart/strix-halo-server:vYYYY.MM.DD-HHMMSS-rRUN_NUMBER
sudo systemctl reboot
```

Each build publishes a `latest` tag and a versioned tag in the form `vYYYY.MM.DD-HHMMSS-rRUN_NUMBER`. See the [published image page](https://github.com/BryanConradHart/strix-halo-server/pkgs/container/strix-halo-server) for available tags.
