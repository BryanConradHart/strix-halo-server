# Strix Halo Server (Arcane Agent Edge)

This image adds the Arcane Edge Agent to the clean Strix Halo image. The agent connects outbound to Arcane Manager, so the host does not need an inbound agent port. The Podman socket gives the manager control over containers on this host; use a trusted Arcane Manager and protect its credentials.

Image: `ghcr.io/bryanconradhart/strix-halo-server-arcane-agent-edge`

## Install

Choose one of these methods:

1. **Existing bootc system:** switch to this image and reboot:

   ```bash
   sudo bootc switch --transport registry ghcr.io/bryanconradhart/strix-halo-server-arcane-agent-edge:latest
   sudo systemctl reboot
   ```

2. **Clean-disk install from a Linux live USB:** boot a [Fedora Workstation live USB](https://fedoraproject.org/workstation/download/), install Podman if needed, use `lsblk` to identify the whole target disk, then run:

   ```bash
   sudo dnf install -y podman
   sudo podman run --rm --privileged --pid=host --ipc=host \
     -v /var/lib/containers:/var/lib/containers -v /dev:/dev \
     --security-opt label=type:unconfined_t \
     ghcr.io/bryanconradhart/strix-halo-server-arcane-agent-edge:latest \
     bootc install to-disk /dev/nvme0n1
   ```

   Replace `/dev/nvme0n1` with the whole-disk device, not a partition. **This erases that disk.** Verify the device before proceeding.

3. **Install from a locally built ISO:** use the [BlueBuild CLI ISO instructions](https://blue-build.org/how-to/generate-iso/) with this image:

   ```bash
   sudo bluebuild generate-iso --iso-name strix-halo-arcane-agent-edge.iso --platform linux/amd64 \
     image ghcr.io/bryanconradhart/strix-halo-server-arcane-agent-edge:latest
   ```

   Write the ISO to a USB drive, boot it, and follow the installer. Writing the ISO erases the USB drive.

## First boot enrollment

In Arcane Manager, add an **Edge** environment and generate the agent configuration. On first boot, enter the Manager URL and generated agent token when prompted. The token is stored only in a root-only file on the host and is not included in the image. If enrollment is skipped or times out, it is offered again at the next boot.

## Updates

Update the operating system image with bootc:

```bash
sudo bootc upgrade
sudo systemctl reboot
```

To pin a specific build, switch to its versioned image tag:

```bash
sudo bootc switch --transport registry ghcr.io/bryanconradhart/strix-halo-server-arcane-agent-edge:vYYYY.MM.DD-HHMMSS-rRUN_NUMBER
sudo systemctl reboot
```

See the [published image page](https://github.com/BryanConradHart/strix-halo-server/pkgs/container/strix-halo-server-arcane-agent-edge) for available tags. Update the agent container through Arcane Manager's environment controls. See the [Arcane Edge documentation](https://getarcane.app/docs/remote/environments) for network and environment setup.
