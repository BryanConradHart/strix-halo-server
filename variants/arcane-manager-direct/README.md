# Strix Halo Server (Arcane Manager Direct Agent)

This image adds the Arcane Direct Agent to the clean Strix Halo image and connects it to an Arcane Manager. Arcane can manage containers on this host through its Podman socket. Access to that socket is highly privileged, so expose the agent only on a trusted network and restrict access to TCP port `3553`.

Image: `ghcr.io/bryanconradhart/strix-halo-server-arcane-manager-direct`

## Install

Choose the option that matches your starting point.

### 1. On a system that already has bootc

Switch to the Arcane Manager Direct Agent image and reboot:

```bash
sudo bootc switch --transport registry ghcr.io/bryanconradhart/strix-halo-server-arcane-manager-direct:latest
sudo systemctl reboot
```

Check whether your current system is bootc-managed with `sudo bootc status`. For uCore installations managed with rpm-ostree, follow the [uCore transition guidance](https://projectucore.org/docs/rebasing/).

### 2. From a live USB

Boot from a [Fedora Workstation live USB](https://fedoraproject.org/workstation/download/). In its terminal, install Podman if needed, identify the target disk, then run:

```bash
sudo dnf install -y podman
lsblk -o NAME,PATH,SIZE,MODEL,TYPE,MOUNTPOINTS

sudo podman run --rm --privileged --pid=host --ipc=host \
  -v /var/lib/containers:/var/lib/containers \
  -v /dev:/dev \
  --security-opt label=type:unconfined_t \
  ghcr.io/bryanconradhart/strix-halo-server-arcane-manager-direct:latest \
  bootc install to-disk /dev/nvme0n1
```

Replace `/dev/nvme0n1` with the whole-disk device identified using `lsblk` (not a partition). The live USB also appears in the list. **This erases the target disk, including all existing data.** Verify the device carefully before running the command. After it completes, shut down, remove the live USB, and boot from the installed disk.

### 3. By building an installable ISO

Use the [BlueBuild CLI](https://blue-build.org/how-to/generate-iso/) to build an ISO from this image:

```bash
sudo bluebuild generate-iso \
  --iso-name strix-halo-arcane-manager-direct.iso \
  --platform linux/amd64 \
  image ghcr.io/bryanconradhart/strix-halo-server-arcane-manager-direct:latest
```

Write the ISO to a USB drive using `dd` or a graphical flashing tool such as balenaEtcher or Rufus. For `dd`:

```bash
sudo dd if=./strix-halo-arcane.iso of=/dev/sdX bs=4M status=progress conv=fsync
```

Replace `/dev/sdX` with the USB device (not a partition); writing the image erases that device. Boot the target computer from the USB drive and follow the installer's on-screen steps to install the image to the system disk.

## First boot enrollment

1. In Arcane Manager, add a **Direct** environment for this host and note the generated `AGENT_TOKEN` and `MANAGER_API_URL`. The Manager URL should be reachable by the agent host.
2. Install and boot this image using one of the options above. On first boot, the system asks for the Manager URL and token through the system password prompt. Enter the values from Arcane; the token is not echoed.
3. The image writes the values to `/etc/arcane/agent.env` with root-only access, starts the agent, and persists the data volume. The enrollment prompt is skipped on subsequent boots.

The first-boot prompt requires a console/password prompt agent. If enrollment is skipped or times out, it is offered again at the next boot. If the agent cannot connect after enrollment, check the URL, port, firewall, and Arcane environment configuration.

The token remains machine-specific host configuration: it is not included in the repository or image and is preserved across bootc updates. Back it up in a password manager or secret manager for disaster recovery. Protect the Manager-generated token and `/etc/arcane/agent.env`; rotate the token if compromised.

## Updates and recovery

Upgrade the OS image with bootc:

```bash
sudo bootc status
sudo bootc upgrade
sudo systemctl reboot
```

For a specific image build, switch to its versioned tag:

```bash
sudo bootc switch --transport registry ghcr.io/bryanconradhart/strix-halo-server-arcane-manager-direct:vYYYY.MM.DD-HHMMSS-rRUN_NUMBER
sudo systemctl reboot
```

Each build publishes a `latest` tag and a versioned tag in the form `vYYYY.MM.DD-HHMMSS-rRUN_NUMBER`. See the [published image page](https://github.com/BryanConradHart/strix-halo-server/pkgs/container/strix-halo-server-arcane-manager-direct) for available tags. Update the agent container through Arcane's environment update controls. For clean recovery, install the same image variant, create or restore the Arcane environment, then enter its token at the first-boot prompt.

Arcane manages containers through Podman's Docker-compatible API. It does not manage arbitrary host systemd services. See Arcane's [remote environment documentation](https://getarcane.app/docs/remote/environments) for Direct Agent networking and environment setup.
