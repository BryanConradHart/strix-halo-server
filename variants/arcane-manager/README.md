# Strix Halo Server (Arcane Manager)

This image adds Arcane Manager for administering local and remote container environments. It exposes the manager web interface on TCP port `3552` and connects to the host's Podman service. Access to the Podman socket allows full control of containers on the host; restrict access to trusted administrators and networks.

Image: `ghcr.io/bryanconradhart/strix-halo-server-arcane-manager`

For installation, follow the shared instructions in the [root README](../../README.md). Complete the Arcane Manager first-boot setup below after installing.

## First boot

Enter the URL that administrators will use to reach Arcane Manager. The image generates an encryption key and stores it with the URL in a root-only host file; neither is included in the image. Open the URL you entered during setup (the default direct connection is `http://<host>:3552`), sign in with the initial credentials `arcane` / `arcane-admin`, and change the password. Use a trusted network and HTTPS through a reverse proxy when accessing the manager remotely.

The manager's data and projects persist across operating-system updates. Back up `/etc/arcane/manager.env` together with Arcane's data if you need to restore the manager.

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

See the [published image page](https://github.com/BryanConradHart/strix-halo-server/pkgs/container/strix-halo-server-arcane-manager) for available tags. Arcane Manager's container image is checked and updated by Podman's automatic update service. See the [Arcane installation guide](https://getarcane.app/docs/get-started/installation) and [remote environment guide](https://getarcane.app/docs/remote/environments) for administration and agent setup.
