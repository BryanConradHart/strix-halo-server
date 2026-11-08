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

Follow uCore's [official first-install instructions](https://projectucore.org/docs/first-install/) for preparing Butane and installing Fedora CoreOS. Use the same selected Strix Halo image and tag in both rebase stages, as described in uCore's guide; the first-boot process then rebases directly to that image.

We recommend booting the target machine into the [Fedora Workstation Live desktop](https://fedoraproject.org/workstation/download/). Its browser lets you read uCore's instructions and use our Butane utility, while its terminal includes Podman to run the [Fedora CoreOS installer container](https://docs.fedoraproject.org/en-US/fedora-coreos/bare-metal/#_installing_from_a_container) against the target disk. This keeps configuration and installation in one session, without needing to transfer the Butane file from another computer.

To prepare the Butane file, either edit the template linked from uCore's guide or use our [graphical Butane utility](https://bryanconradhart.github.io/strix-halo-server/install/), which helps select a Strix Halo variant and tag, can hash a password locally in the browser or accept an existing hash, and can configure supported variant setup values. Follow uCore's official instructions to apply the configuration and install.

For Arcane Manager, Arcane Edge Agent, Arcane Direct Agent, and Lemonade Server, the graphical utility can also provision the variant's first-boot settings, matching its setup script. Each variant README links to the builder with that variant selected. These optional settings are written into the downloaded Butane configuration; keep that file private.

After installation, you may use `bootc` to switch to another variant as described in [Switch an existing bootc system](#1-switch-an-existing-bootc-system).
