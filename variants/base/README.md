# Strix Halo Server (Base)

The clean Strix Halo image. It includes the shared 128 GB Strix hardware configuration, Wi-Fi and Bluetooth support, Mesa Vulkan drivers, `clinfo`, `rocminfo`, and the tuned performance profile setup. It does not include workload-specific software or the Arcane Agent.

Image: `ghcr.io/bryanconradhart/strix-halo-server`

## Install

On a system already managed by bootc, switch to this image and reboot:

```bash
sudo bootc switch --transport registry ghcr.io/bryanconradhart/strix-halo-server:latest
sudo systemctl reboot
```

For a clean installation on new hardware, boot a live environment such as the [Fedora Workstation Live image](https://fedoraproject.org), connect to the network, and install the image directly onto the target drive. Identify the drive with `lsblk -o NAME,SIZE,MODEL,TYPE,MOUNTPOINTS` — the command below erases it, so double-check the device path and do not select the live USB:

```bash
sudo podman run --rm --privileged --pid=host \
  -v /var/lib/containers:/var/lib/containers \
  -v /dev:/dev \
  --security-opt label=type:unconfined_t \
  ghcr.io/bryanconradhart/strix-halo-server:latest \
  bootc install to-disk --wipe --generic-image /dev/REPLACE_WITH_TARGET_DISK
```

Reboot, then sign in as `core` with the temporary password `core` and choose a new password. For a headless install, mount your public key into the container with `-v "$HOME/.ssh/id_ed25519.pub:/tmp/key.pub:ro"` and add `--root-ssh-authorized-keys /tmp/key.pub` to the install command; the key authorizes root, and first boot also installs it for `core`. See the root [installation instructions](../../README.md) for the full details.

The base image has no interactive first-boot script or additional variant setup.

## Wireless connectivity

Wi-Fi is managed by NetworkManager. To connect or change networks, list nearby networks and connect with a password prompt; NetworkManager retains the connection, so there is no setup script to rerun:

```bash
nmcli device wifi list
nmcli device wifi connect "NETWORK_NAME" --ask
```

Bluetooth support and device firmware are included, and `bluetooth.service` starts at boot. Use `bluetoothctl` to pair and connect Bluetooth devices.

## Running your own containers

The base image ships no workload services; deploy long-running containers as rootful Podman Quadlet files in `/etc/containers/systemd/`, which survives `bootc upgrade` and `bootc switch`. Quadlet services start at boot, are managed with `systemctl`, are restarted at boot by `podman-restart.service` (enabled in this image), and update themselves via `podman-auto-update.timer` when you set `AutoUpdate=registry`. Do not use docker-compose or podman-compose for deployed services. A minimal service looks like this:

```ini
# /etc/containers/systemd/hello.container
[Container]
Image=docker.io/library/nginx:alpine
PublishPort=8080:80

[Install]
WantedBy=multi-user.target
```

Then generate and start it:

```bash
sudo systemctl daemon-reload
sudo systemctl start hello.service
```

## Updates

After installation, upgrades are handled through bootc. Check the current image state and upgrade to the newest build:

```bash
sudo bootc status
sudo bootc upgrade
sudo systemctl reboot
```

To switch directly to a specific image tag:

```bash
sudo bootc switch --transport registry ghcr.io/bryanconradhart/strix-halo-server:vYYYY.MM.DD-HHMMSS-rRUN_NUMBER
sudo systemctl reboot
```

Each build publishes a `latest` tag and a versioned tag in the form `vYYYY.MM.DD-HHMMSS-rRUN_NUMBER`. See the [published image page](https://github.com/BryanConradHart/strix-halo-server/pkgs/container/strix-halo-server) for available tags.
