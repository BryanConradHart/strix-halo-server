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

Choose a variant from the table and copy its image reference. Use that image in one of the following options. After installation, visit the variant's README for any first-boot prompts and application-specific setup.

If Secure Boot is enabled, follow uCore's [Secure Boot guide](https://projectucore.org/docs/secure-boot/). For a clean install, temporarily disable it, install and switch to the selected image, enroll the key, then re-enable it.

### 1. Switch an existing bootc system

On a system managed by bootc, replace `IMAGE_FROM_TABLE` with the image from the table, then switch and reboot:

```bash
sudo bootc switch --transport registry IMAGE_FROM_TABLE:latest
sudo systemctl reboot
```

### 2. Bare-metal installation

uCore installs with Butane and Ignition. The steps here make [uCore's installation guidance](https://projectucore.org/docs/first-install/#prepare-your-butane-configuration) less abstract by automatically filling in [its example Butane file](https://github.com/ublue-os/ucore/blob/main/examples/ucore-autorebase.butane) with the selected image and your credentials. If you prefer, you can instead write your own Butane configuration and generate the Ignition file following uCore's guide.

Download the x86_64 live ISO from the [Fedora CoreOS downloads](https://fedoraproject.org/coreos/download/?stream=stable#baremetal) page. Write the ISO image to a USB drive using [Fedora Media Writer](https://fedoraproject.org/workstation/download/) (Windows, macOS, or Linux), [Rufus](https://rufus.ie/) (Windows), or [balenaEtcher](https://etcher.balena.io/) (macOS or Linux). Writing the image erases the USB drive. Boot the target computer from that USB. Once Fedora CoreOS starts, open a terminal and connect to the internet. Then download and run the helper:

```bash
curl -fsSLO https://raw.githubusercontent.com/BryanConradHart/strix-halo-server/main/scripts/prepare-install-ignition.sh
bash prepare-install-ignition.sh IMAGE_FROM_TABLE:latest
```

Replace `IMAGE_FROM_TABLE` with the image from the table. The helper prompts for the `core` account password. To enable remote SSH login, pass a public key as the optional second argument; the installed system will accept connections authenticated with its matching private key.

Alternatively, write your own Butane configuration and compile it to `ucore-autorebase.ign` using [uCore's installation guide](https://projectucore.org/docs/first-install/#prepare-your-butane-configuration). If you start from uCore's sample, replace both image references with the selected image from the table.

List disks and identify the target using its size and model:

```bash
lsblk -o NAME,PATH,SIZE,MODEL,TYPE,MOUNTPOINTS
```

Before running the install command, replace `/dev/nvme0n1` with the target's whole-disk path from `lsblk` (for example, `/dev/sda` or `/dev/nvme0n1`), not a partition. **This erases all data on that disk. Verify the device path carefully.**

```bash
sudo coreos-installer install /dev/nvme0n1 \
  --ignition-file "$PWD/ucore-autorebase.ign"
```

Keep networking connected through the automatic first-boot setup and reboots. The system should then be running the selected Strix image; sign in as `core`.
