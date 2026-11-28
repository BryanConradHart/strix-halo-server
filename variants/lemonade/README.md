# Strix Halo Server (Lemonade)

This image packages [Lemonade Server](https://lemonade-server.ai/), an upstream local AI server providing APIs for chat, coding, speech, image generation, and embeddings. It uses the AMD GPU devices and publishes the API on TCP port `13305`.

Image: `ghcr.io/bryanconradhart/strix-halo-server-lemonade`

## Install

On a system already managed by bootc, switch to this image and reboot:

```bash
sudo bootc switch --transport registry ghcr.io/bryanconradhart/strix-halo-server-lemonade:latest
sudo systemctl reboot
```

For a clean installation on new hardware, boot a live environment such as the [Fedora Workstation Live image](https://fedoraproject.org), connect to the network, and install the image directly onto the target drive. Identify the drive with `lsblk -o NAME,SIZE,MODEL,TYPE,MOUNTPOINTS` — the command below erases it, so double-check the device path and do not select the live USB:

```bash
sudo podman run --rm --privileged --pid=host \
  -v /var/lib/containers:/var/lib/containers \
  -v /dev:/dev \
  --security-opt label=type:unconfined_t \
  ghcr.io/bryanconradhart/strix-halo-server-lemonade:latest \
  bootc install to-disk --wipe --generic-image /dev/REPLACE_WITH_TARGET_DISK
```

Reboot, then sign in as `core` with the temporary password `core` and choose a new password. For a headless install, mount your public key into the container with `-v "$HOME/.ssh/id_ed25519.pub:/tmp/key.pub:ro"` and add `--root-ssh-authorized-keys /tmp/key.pub` to the install command; the key authorizes root, and first boot also installs it for `core`. See the root [installation instructions](../../README.md) for the full details.

## Install with customization

A drop-in can be applied to a running system, or during a bare-metal install as shown below, where it is active from the first boot. Write one with any editor, anywhere — say `~/20-custom.conf` — then run the bare-metal install command above and, before rebooting, copy your files into the installed system:

```bash
sudo mkdir -p /mnt/newroot
sudo mount /dev/REPLACE_WITH_ROOT_PARTITION /mnt/newroot
sudo install -D -m 0644 ~/20-custom.conf \
  /mnt/newroot/sysroot/ostree/deploy/*/deploy/*.0/etc/containers/systemd/lemonade-server.container.d/20-custom.conf
# Only if your drop-in references an env file (see "Provide the API key yourself"):
sudo install -D -m 0600 ~/server-user.env \
  /mnt/newroot/sysroot/ostree/deploy/*/deploy/*.0/etc/lemonade/server-user.env
sudo umount /mnt/newroot
```

Each example below is a snippet of `20-custom.conf`; combine the ones you want into that single file. On first login, setup asks for any required values you haven't supplied. To build a drop-in interactively instead of writing one by hand, use the [drop-in generator](https://bryanconradhart.github.io/strix-halo-server/dropins/lemonade.html).

**Provide the API key yourself**, for example to rotate it. The key is a secret, so keep it out of the drop-in — inline values are visible to any local user — by referencing an env file. Create `~/server-user.env` containing `LEMONADE_API_KEY=…`; the install command above copies it root-only alongside the drop-in (the service won't start if the file is missing):

```ini
# 20-custom.conf
[Container]
EnvironmentFile=/etc/lemonade/server-user.env
```

Your `EnvironmentFile=` is applied after setup's `/etc/lemonade/server.env`, so your key wins. Update clients to use it.

**Publish the API on a different port** (drop-ins add to the defaults, so clear the list first to replace it):

```ini
# 20-custom.conf
[Container]
PublishPort=
PublishPort=9527:13305
```

**Keep models on a host directory** instead of the container-managed volume. Clearing `Volume=` drops the shipped volumes too, so restate the ones to keep:

```ini
# 20-custom.conf
[Container]
Volume=
Volume=lemonade-cache:/opt/lemonade/.cache/huggingface
Volume=lemonade-llama:/opt/lemonade/llama
Volume=lemonade-data:/opt/lemonade/.cache/lemonade
Volume=lemonade-config:/opt/lemonade/.config/lemonade
Volume=/srv/models:/opt/lemonade/models
```

Merge rules — how settings combine and how to clear a list — are in the [customization guide](../../README.md#customizing-services-with-quadlet-drop-ins). Never copy the whole shipped unit into `/etc` to edit it: the copy blocks all future updates to the service.

## Setup after first login

After installing the image and signing in, setup is offered automatically if it has not been completed. The API key is stored in `/etc/lemonade/server.env` with root-only access; it is not included in the image. Keep it available for clients connecting to `http://<host>:13305`; provide it as the client's API key. Model and server data persist across operating-system updates.

If you supplied the API key through a drop-in during [Install with customization](#install-with-customization), setup is not offered and the server starts on boot.

If you deferred setup, run it manually with:

```bash
sudo /usr/libexec/lemonade-server-enroll.sh
```

The login offer is suppressed when `/etc/lemonade/server.env` exists. To replace the API key, stop the server, back up the existing key file, and run setup again. The script replaces the file even if it already exists. Update clients to use the new key; keep the backup private:

```bash
sudo systemctl stop lemonade-server.service
sudo mv /etc/lemonade/server.env /etc/lemonade/server.env.backup
sudo /usr/libexec/lemonade-server-enroll.sh
```

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

See the [published image page](https://github.com/BryanConradHart/strix-halo-server/pkgs/container/strix-halo-server-lemonade) for available tags. The server container follows the upstream stable image and is updated by Podman's automatic update service. This image's service unit follows the official [Lemonade container installation guide](https://lemonade-server.ai/docs/guide/install/docker/); consult the [Lemonade Server documentation](https://lemonade-server.ai/docs/) for API use and model setup.
