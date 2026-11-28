# Strix Halo Server

Lightweight, reproducible bootc images for AMD Strix Halo systems, tuned for local AI, development, and self-hosted compute. They package the hardware-specific configuration and update through bootc, so you can get started without assembling and maintaining those pieces yourself. Choose the clean base or an optional workload-specific variant; all are published to GHCR.

## Available images

| Variant | Image | Description |
| --- | --- | --- |
| [Base](variants/base/README.md) | `ghcr.io/bryanconradhart/strix-halo-server` | Clean Strix Halo platform based on [single-purpose-os-base](https://github.com/BryanConradHart/single-purpose-os), with shared hardware configuration, Mesa Vulkan drivers, and hardware inspection tools. |
| [Arcane Manager](variants/arcane-manager/README.md) | `ghcr.io/bryanconradhart/strix-halo-server-arcane-manager` | The base platform plus [Arcane](https://github.com/getarcaneapp/arcane) for administering local and remote container environments. Extends [single-purpose-os-arcane-manager](https://github.com/BryanConradHart/single-purpose-os). |
| [Arcane Agent](variants/arcane-agent/README.md) | `ghcr.io/bryanconradhart/strix-halo-server-arcane-agent` | The base platform plus the [Arcane agent](https://github.com/getarcaneapp/arcane) for hosts that connect outbound to Arcane Manager. Extends [single-purpose-os-arcane-agent](https://github.com/BryanConradHart/single-purpose-os). |
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

*(Optional)* To add an SSH public key for headless login on first boot, pass your key file into the container and include `--root-ssh-authorized-keys`. The key authorizes root, and first boot also installs it for `core`, so you can sign in as either. If you don't have a key pair yet, create one first with `ssh-keygen -t ed25519` and use the generated `.pub` file:

```bash
sudo podman run --rm --privileged --pid=host \
  -v /var/lib/containers:/var/lib/containers \
  -v /dev:/dev \
  -v "$HOME/.ssh/id_ed25519.pub:/tmp/key.pub:ro" \
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

### Customizing by extending an image (advanced)

Customizations that suit an image — packages, files, units, services — are best baked in by building your own [BlueBuild](https://blue-build.org/) image on top of one of ours. Baked configuration travels with the image: a new install arrives already configured. For advanced users; the variants here are working examples of extending the [single-purpose-os](https://github.com/BryanConradHart/single-purpose-os) images, and the [BlueBuild setup guide](https://blue-build.org/how-to/setup/) covers the CI side.

A minimal recipe (`recipes/home-lab.yml`):

```yaml
name: home-lab
base-image: ghcr.io/bryanconradhart/strix-halo-server
image-version: latest
modules:
  - type: dnf
    install:
      packages:
        - htop
```

Publish to your own registry, then point the host at your image once, and follow the existing installation instructions for the variant you extended:

```bash
sudo bootc switch --transport registry ghcr.io/YOUR_GITHUB_USER/home-lab:latest
sudo systemctl reboot
```

Your image inherits our kernel arguments, hardware configuration, services, and setup scripts, and picks up our changes whenever you rebuild on a newer `image-version`.

### Customizing services with Quadlet drop-ins

Drop-ins add host customization on top of a baked image — ours or one you built — without rebuilding it. Use them for settings that shouldn't be baked into the image, such as machine-specific values in an image shared across hosts, or secrets. A drop-in is a small configuration file merged into the service definition at boot, so mounts, ports, and environment values can vary per host. Drop-ins live in `/etc/containers/systemd/<service>.container.d/` and survive updates.

Create a drop-in with any editor, for example `20-extra-mount.conf`:

```ini
[Container]
Volume=/srv/shared-data:/srv/shared-data:ro
```

To have it active from the first boot, place it on the target system while installing with `bootc install to-disk`: after the installer finishes and before you reboot, mount the installed system's root partition (check with `lsblk`; for example `/dev/nvme0n1p3`) and copy the file into the deployment's `/etc`:

```bash
sudo mkdir -p /mnt/newroot
sudo mount /dev/REPLACE_WITH_ROOT_PARTITION /mnt/newroot
sudo install -D -m 0644 20-extra-mount.conf \
  /mnt/newroot/sysroot/ostree/deploy/*/deploy/*.0/etc/containers/systemd/<service>.container.d/20-extra-mount.conf
sudo umount /mnt/newroot
```

Drop-ins can also be added to a running system. Name your drop-ins `20-` or higher so they sort after the ones setup creates: setup regenerates its own files, and yours are never touched.

Gotchas:

- Drop-ins are applied in lexicographic (alphabetical) filename order — `aaa` comes before `aab`, `10-` comes before `20-`.
- Single-value settings (`Image=`, `Memory=`): the last assignment wins.
- List settings (`Volume=`, `PublishPort=`): assignments accumulate and entries never collide. Assigning an empty value (`Volume=`) resets the list, so restate anything you want to keep after it.
- Keyed list settings (`Environment=`): assignments accumulate, and re-assigning the same key (`FOO=`) overrides its earlier value. Assigning an empty value (`Environment=`) resets the list.
- `EnvironmentFile=` is a list setting: each entry adds a file. The files are expanded into the same keyed list when the container starts, in the order listed, so a key in a later file overrides the same key from an earlier file.
- Inline `Environment=` entries are applied after all env files, so they override any file value.
- Don't put credentials in inline `Environment=` values; keep them in a file referenced by `EnvironmentFile=`. Inline values can be read back with `systemctl show` or from the process list.
- Write an env file before the drop-in that references it — the service won't start if the file is missing.
- Bring a setting into your own drop-in only when you intend to change it. Re-declaring the shipped unit or a setup-created drop-in just to edit one line freezes the rest of that layer against future updates.

The variant READMEs list drop-in examples for each service.

