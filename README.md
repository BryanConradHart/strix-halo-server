# Strix Halo Server

Lightweight, reproducible bootc images for AMD Strix Halo systems, tuned for local AI, development, and self-hosted compute. They package the hardware-specific configuration and update through bootc, so you can get started without assembling and maintaining those pieces yourself. Choose the clean base or an optional workload-specific variant; all are published to GHCR.

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

Choose a variant from the table and copy its image reference. Use that image in one of the following options. After installation, visit the variant's README for setup offered after login and application-specific instructions.

### 1. Switch an existing bootc system

On a system managed by bootc, replace `IMAGE_FROM_TABLE` with the image from the table, then switch and reboot:

```bash
sudo bootc switch --transport registry IMAGE_FROM_TABLE:latest
sudo systemctl reboot
```

### 2. Bare-metal installation

#### uCore's Official First-Install Guide

Install uCore by following [uCore's official first-install instructions](https://projectucore.org/docs/first-install/).

#### Streamlined Strix Halo Server install instructions

The steps below apply uCore's official first-install process to Strix Halo Server, using a prepared configuration and commands for this project's images.

Create a bootable USB from the [Fedora Workstation Live image](https://fedoraproject.org/workstation/download/) and boot the Strix Halo Server from it.
Once the live desktop starts, connect to the network and open this README in the browser.
Use the [Butane utility](https://bryanconradhart.github.io/strix-halo-server/install/) to generate and download `strix-halo-server.butane` for the image you want to install.

> [!WARNING]
> The file contains your account password hash and may contain application credentials, so keep it private.

Open the terminal and go to the directory where the browser saved the file (usually `Downloads`).
Before installing, compile the Butane file to Ignition to catch configuration errors before writing to a disk. If the command reports an error, fix the configuration in the utility and download it again; continue only after it succeeds.

```bash
podman run --interactive --rm quay.io/coreos/butane:release \
  --pretty --strict < strix-halo-server.butane > strix-halo-server.ign
```

Next, identify the computer's internal target drive:

```bash
lsblk -o NAME,SIZE,MODEL,TYPE,MOUNTPOINTS
```

Check the drive's name, size, and model carefully. The next command erases the selected drive; use the whole drive (for example, `/dev/nvme0n1`), not a partition (such as `/dev/nvme0n1p1`), and do not select the live USB. Replace `/dev/REPLACE_WITH_TARGET_DISK` with that drive's device path:

```bash
sudo podman run --pull=always --privileged --rm \
  -v /dev:/dev -v /run/udev:/run/udev -v "$PWD:/data" -w /data \
  quay.io/coreos/coreos-installer:release \
  install /dev/REPLACE_WITH_TARGET_DISK --ignition-file strix-halo-server.ign
```

When the installer finishes, remove the live USB and restart the computer:

```bash
sudo systemctl reboot
```

Leave the computer connected to the network. Expect it to restart a few times while uCore completes its first-boot setup and switches to the selected image. Let the process finish; it will eventually stop at the installed system's login screen. Sign in as `core` with the password you configured. See the selected variant's README for its post-login setup and application instructions.

#### After installation

To switch to a different image later, use `bootc` as described in [Switch an existing bootc system](#1-switch-an-existing-bootc-system).
