# Strix Halo Server (AI Toolbox Cockpit)

This image adds the AI Toolbox Cockpit interactive terminal app for managing AI toolboxes, models, and local inference servers. The app supports Strix Halo in its platform catalog and uses Podman and Distrobox for its container workflows.

Image: `ghcr.io/bryanconradhart/strix-halo-server-ai-toolbox-cockpit`

## Install

Choose one of these methods:

1. **Existing bootc system:** switch to this image and reboot:

   ```bash
   sudo bootc switch --transport registry ghcr.io/bryanconradhart/strix-halo-server-ai-toolbox-cockpit:latest
   sudo systemctl reboot
   ```

2. **Clean-disk install from a Linux live USB:** boot a [Fedora Workstation live USB](https://fedoraproject.org/workstation/download/), install Podman if needed, use `lsblk` to identify the whole target disk, then run:

   ```bash
   sudo dnf install -y podman
   sudo podman run --rm --privileged --pid=host --ipc=host \
     -v /var/lib/containers:/var/lib/containers -v /dev:/dev \
     --security-opt label=type:unconfined_t \
     ghcr.io/bryanconradhart/strix-halo-server-ai-toolbox-cockpit:latest \
     bootc install to-disk /dev/nvme0n1
   ```

   Replace `/dev/nvme0n1` with the whole-disk device, not a partition. **This erases that disk.** Verify the device before proceeding.

3. **Install from a locally built ISO:** use the [BlueBuild CLI ISO instructions](https://blue-build.org/how-to/generate-iso/) with this image:

   ```bash
   sudo bluebuild generate-iso --iso-name strix-halo-ai-toolbox-cockpit.iso --platform linux/amd64 \
     image ghcr.io/bryanconradhart/strix-halo-server-ai-toolbox-cockpit:latest
   ```

   Write the ISO to a USB drive, boot it, and follow the installer. Writing the ISO erases the USB drive.

## Use

After signing in, run:

```bash
ai-toolbox-cockpit
```

The app is installed from a pinned upstream revision. It uses the signed-in user's Podman account to create and run toolboxes. See the [AI Toolbox Cockpit documentation](https://github.com/kyuz0/ai-toolbox-cockpit) for supported backends, models, and controls.

## Updates

Update the operating system image with bootc:

```bash
sudo bootc upgrade
sudo systemctl reboot
```

To pin a specific build, switch to its versioned image tag:

```bash
sudo bootc switch --transport registry ghcr.io/bryanconradhart/strix-halo-server-ai-toolbox-cockpit:vYYYY.MM.DD-HHMMSS-rRUN_NUMBER
sudo systemctl reboot
```

See the [published image page](https://github.com/BryanConradHart/strix-halo-server/pkgs/container/strix-halo-server-ai-toolbox-cockpit) for available tags. The Cockpit app version changes when this image recipe is updated to a newer upstream revision.
