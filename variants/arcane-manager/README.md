# Strix Halo Server (Arcane Manager)

This image adds Arcane Manager for administering local and remote container environments on the Strix Halo platform. It exposes the manager web interface on TCP port `3552` and connects to the host's Podman service. Access to the Podman socket allows full control of containers on the host; restrict access to trusted administrators and networks.

For rootful Podman systemd and Quadlet management, the manager runs as root in its container, mounts the host system D-Bus socket, and shares the writable `/etc/containers/systemd` directory used for installed Quadlets. Treat manager access as privileged host administration.

Image: `ghcr.io/bryanconradhart/strix-halo-server-arcane-manager`

This image extends [single-purpose-os-arcane-manager](https://github.com/BryanConradHart/single-purpose-os/blob/main/variants/arcane-manager/README.md) with the Strix Halo hardware configuration, so the Arcane setup and administration instructions there apply unchanged.

## Install

On a system already managed by bootc, switch to this image and reboot:

```bash
sudo bootc switch --transport registry ghcr.io/bryanconradhart/strix-halo-server-arcane-manager:latest
sudo systemctl reboot
```

For a clean installation on new hardware, boot a live environment such as the [Fedora Workstation Live image](https://fedoraproject.org), connect to the network, and install the image directly onto the target drive. Identify the drive with `lsblk -o NAME,SIZE,MODEL,TYPE,MOUNTPOINTS` — the command below erases it, so double-check the device path and do not select the live USB:

```bash
sudo podman run --rm --privileged --pid=host \
  -v /var/lib/containers:/var/lib/containers \
  -v /dev:/dev \
  --security-opt label=type:unconfined_t \
  ghcr.io/bryanconradhart/strix-halo-server-arcane-manager:latest \
  bootc install to-disk --wipe --generic-image /dev/REPLACE_WITH_TARGET_DISK
```

Reboot, then sign in as `core` with the temporary password `core` and choose a new password. For a headless install, mount your public key into the container with `-v "$HOME/.ssh/id_ed25519.pub:/tmp/key.pub:ro"` and add `--root-ssh-authorized-keys /tmp/key.pub` to the install command; the key authorizes root, and first boot also installs it for `core`. See the root [installation instructions](../../README.md) for the full details.

## Install with customization

A drop-in can be applied to a running system, or during a bare-metal install as shown below, where it is active from the first boot. Write one with any editor, anywhere — say `~/20-custom.conf` — then run the bare-metal install command above and, before rebooting, copy your files into the installed system:

```bash
sudo mkdir -p /mnt/newroot
sudo mount /dev/REPLACE_WITH_ROOT_PARTITION /mnt/newroot
sudo install -D -m 0644 ~/20-custom.conf \
  /mnt/newroot/sysroot/ostree/deploy/*/deploy/*.0/etc/containers/systemd/arcane-manager.container.d/20-custom.conf
# Only if your drop-in references an env file (see "Supply the encryption key yourself"):
sudo install -D -m 0600 ~/manager-user.env \
  /mnt/newroot/sysroot/ostree/deploy/*/deploy/*.0/etc/arcane/manager-user.env
sudo umount /mnt/newroot
```

Each example below is a snippet of `20-custom.conf`; combine the ones you want into that single file. Setup writes its own `10-projects.conf` to the same directory, so keep your file at `20-` or higher: setup never touches your files, and on login it asks only for required values you haven't supplied.

**Store projects on a host path** (without this, projects are lost when the container updates). Setup asks for the location and writes this itself; the drop-in answers for it at install time:

```ini
# 20-custom.conf
[Container]
Volume=/srv/arcane-projects:/opt/docker
Environment=ARCANE_PROJECTS_DIRECTORY=/opt/docker
```

Podman creates the host directory on first start. To move projects after setup ran, edit `10-projects.conf` — setup's own comment says so; adding a second projects mount with your own file would collide with it.

**Set the URL administrators use to reach the manager:**

```ini
# 20-custom.conf
[Container]
Environment=ARCANE_APP_URL=https://arcane.example.com
```

**Publish a different port** (drop-ins add to the defaults, so clear the list first to replace it):

```ini
# 20-custom.conf
[Container]
PublishPort=
PublishPort=8443:3552
```

**Supply the encryption key yourself**, for example to restore one from backup instead of accepting the key setup generates. Keep it out of the drop-in — inline values are visible to any local user — by referencing an env file. Create `~/manager-user.env` containing `ARCANE_ENCRYPTION_KEY=…`; the install command above copies it root-only alongside the drop-in (the service won't start if the file is missing):

```ini
# 20-custom.conf
[Container]
EnvironmentFile=/etc/arcane/manager-user.env
```

Your `EnvironmentFile=` is applied after setup's `/etc/arcane/manager.env`, so your key wins.

Merge rules — how settings combine and how to clear a list — are in the [customization guide](../../README.md#customizing-services-with-quadlet-drop-ins). Never copy the whole shipped unit into `/etc` to edit it: the copy blocks all future updates to the service.

## Setup after first login

After installing the image and signing in, setup is offered automatically if it has not been completed. It configures the URL administrators will use to reach Arcane Manager and asks where to store projects. If you supplied those values through a drop-in during [Install with customization](#install-with-customization), setup skips them; it always generates the encryption key unless you supplied one too.

The setup saves the URL and encryption key to `/etc/arcane/manager.env` (root-only). Back the file up together with Arcane's data: if the key is lost, existing manager data becomes inaccessible. Never change the key once set — existing data cannot be re-encrypted.

Open the configured URL (direct access is `http://<host>:3552`) and sign in as `arcane`. Arcane generates the initial password on first start and writes it to `initial-admin-password` inside its data volume, then requires a new password at first login:

```bash
sudo podman exec arcane-manager cat /app/data/initial-admin-password
```

Restrict access to trusted administrators; use HTTPS through a reverse proxy when accessing the manager remotely.

To change the URL later, set it in a drop-in of your own — inline values win over setup's env file, and your change stays separate from the file holding the encryption key (see `ARCANE_APP_URL` in [Install with customization](#install-with-customization)) — then apply it:

```bash
sudo systemctl daemon-reload
sudo systemctl restart arcane-manager.service
```

Do not rerun the setup script after setup: it generates a new encryption key, which can make existing manager data inaccessible.

The manager's data persists across operating-system updates.

## Updates

Update the operating system image with bootc:

```bash
sudo bootc upgrade
sudo systemctl reboot
```

To pin a specific build, switch to its versioned image tag:

```bash
sudo bootc switch --transport registry ghcr.io/bryanconradhart/strix-halo-server-arcane-manager:vYYYY.MM.DD-HHMMSS-rRUN_NUMBER
sudo systemctl reboot
```

See the [published image page](https://github.com/BryanConradHart/strix-halo-server/pkgs/container/strix-halo-server-arcane-manager) for available tags. Arcane Manager's container image updates itself through Podman's automatic update service. See the [Arcane installation guide](https://getarcane.app/docs/get-started/installation), the [Podman setup guide](https://getarcane.app/docs/podman/setup), and the [agents guide](https://getarcane.app/docs/remote/agents) for administration and remote environment setup.
