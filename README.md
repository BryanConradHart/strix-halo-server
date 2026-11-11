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

Create a bootable USB and boot the Strix Halo Server from it. We recommend the [Fedora Workstation Live image](https://fedoraproject.org) because it has a desktop environment so you can access the instructions on the same system.
Once the live desktop starts, connect to the network and open a terminal.

Identify the computer's internal target drive:

```bash
lsblk -o NAME,SIZE,MODEL,TYPE,MOUNTPOINTS
```

Check the drive's name, size, and model carefully. The next command erases the selected drive; use the whole drive (for example, `/dev/nvme0n1`), not a partition (such as `/dev/nvme0n1p1`), and do not select the live USB.

Choose a variant from the [Available images](#available-images) table and copy its image reference. Replace `IMAGE_FROM_TABLE` with that image reference and `/dev/REPLACE_WITH_TARGET_DISK` with your target drive's device path:

```bash
sudo podman run --rm --privileged --pid=host \
  -v /var/lib/containers:/var/lib/containers \
  -v /dev:/dev \
  --security-opt label=type:unconfined_t \
  IMAGE_FROM_TABLE:latest \
  bootc install to-disk --wipe --generic-image /dev/REPLACE_WITH_TARGET_DISK
```

*(Optional)* To add an SSH public key for headless login on first boot, pass your key file into the container and include `--root-ssh-authorized-keys`:

```bash
sudo podman run --rm --privileged --pid=host \
  -v /var/lib/containers:/var/lib/containers \
  -v /dev:/dev \
  -v "\$HOME/.ssh/id_ed25519.pub:/tmp/key.pub:ro" \
  --security-opt label=type:unconfined_t \
  IMAGE_FROM_TABLE:latest \
  bootc install to-disk --wipe --generic-image \
  --root-ssh-authorized-keys /tmp/key.pub \
  /dev/REPLACE_WITH_TARGET_DISK
```

When the installer finishes, remove the live USB and restart the computer:

```bash
sudo systemctl reboot
```

On first boot, sign in at the login prompt as `core` with the temporary password `core`. You will immediately be prompted to choose a new password. Once your password is updated, see the selected variant's README for its post-login setup and application instructions.


#### After installation

To switch to a different image later, use `bootc` as described in [Switch an existing bootc system](#1-switch-an-existing-bootc-system).
