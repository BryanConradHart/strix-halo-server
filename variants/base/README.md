# Strix Halo Server (Base)

The clean Strix Halo image. It includes the shared 128 GB Strix hardware configuration, Wi-Fi and Bluetooth support, Mesa Vulkan drivers, `clinfo`, `rocminfo`, and the tuned performance profile setup. It does not include workload-specific software or the Arcane Agent.

Image: `ghcr.io/bryanconradhart/strix-halo-server`

Install this image using the shared [installation instructions](../../README.md). The base image has no interactive first-boot script or additional variant setup.

## Wireless connectivity

Wi-Fi is managed by NetworkManager. To connect or change networks, list nearby networks and connect with a password prompt; NetworkManager retains the connection, so there is no setup script to rerun:

```bash
nmcli device wifi list
nmcli device wifi connect "NETWORK_NAME" --ask
```

Bluetooth support and device firmware are included, and `bluetooth.service` starts at boot. Use `bluetoothctl` to pair and connect Bluetooth devices.

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
