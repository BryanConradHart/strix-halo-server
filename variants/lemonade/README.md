# Strix Halo Server (Lemonade)

This image adds Lemonade Server, which provides local AI APIs for chat, coding, speech, image generation, and embeddings. It uses the AMD GPU devices and publishes the API on TCP port `13305`.

Image: `ghcr.io/bryanconradhart/strix-halo-server-lemonade`

## Install

Choose one of these methods:

1. **Existing bootc system:** switch to this image and reboot:

   ```bash
   sudo bootc switch --transport registry ghcr.io/bryanconradhart/strix-halo-server-lemonade:latest
   sudo systemctl reboot
   ```

2. **Clean-disk install from a Linux live USB:** boot a [Fedora Workstation live USB](https://fedoraproject.org/workstation/download/), install Podman if needed, use `lsblk` to identify the whole target disk, then run:

   ```bash
   sudo dnf install -y podman
   sudo podman run --rm --privileged --pid=host --ipc=host \
     -v /var/lib/containers:/var/lib/containers -v /dev:/dev \
     --security-opt label=type:unconfined_t \
     ghcr.io/bryanconradhart/strix-halo-server-lemonade:latest \
     bootc install to-disk /dev/nvme0n1
   ```

   Replace `/dev/nvme0n1` with the whole-disk device, not a partition. **This erases that disk.** Verify the device before proceeding.

3. **Install from a locally built ISO:** use the [BlueBuild CLI ISO instructions](https://blue-build.org/how-to/generate-iso/) with this image:

   ```bash
   sudo bluebuild generate-iso --iso-name strix-halo-lemonade.iso --platform linux/amd64 \
     image ghcr.io/bryanconradhart/strix-halo-server-lemonade:latest
   ```

   Write the ISO to a USB drive, boot it, and follow the installer. Writing the ISO erases the USB drive.

## First boot and use

Choose an API key of at least 32 letters, numbers, underscores, or hyphens at the first-boot prompt. The key is stored in a root-only file on the host, not in the image. Keep it available for clients that connect to `http://<host>:13305`; provide it as the client's API key. Model and server data persist across operating-system updates.

## Updates

Update the operating system image with bootc:

```bash
sudo bootc upgrade
sudo systemctl reboot
```

To pin a specific build, switch to its versioned image tag:

```bash
sudo bootc switch --transport registry ghcr.io/bryanconradhart/strix-halo-server-lemonade:vYYYY.MM.DD-HHMMSS-rRUN_NUMBER
sudo systemctl reboot
```

See the [published image page](https://github.com/BryanConradHart/strix-halo-server/pkgs/container/strix-halo-server-lemonade) for available tags. The server container follows the upstream stable image and is updated by Podman's automatic update service. See the [Lemonade Server documentation](https://lemonade-server.ai/docs/) for API use and model setup.
