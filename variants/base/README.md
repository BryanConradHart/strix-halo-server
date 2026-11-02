# Strix Halo Server (Base)

The clean Strix Halo image. It includes the shared 128 GB Strix hardware configuration, Mesa Vulkan drivers, `clinfo`, `rocminfo`, and the tuned performance profile setup. It does not include workload-specific software or the Arcane Agent.

Image: `ghcr.io/bryanconradhart/strix-halo-server`

For installation, follow the shared instructions in the [root README](../../README.md). After installation, this base image needs no variant-specific first-boot setup.

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
