# Strix Halo Server (Arcane Manager)

This image adds Arcane Manager for administering local and remote container environments on the Strix Halo platform. It exposes the manager web interface on TCP port `3552` and connects to the host's Podman service. Access to the Podman socket allows full control of containers on the host; restrict access to trusted administrators and networks.

For rootful Podman systemd and Quadlet management, the manager runs as root in its container, mounts the host system D-Bus socket, and shares the writable `/etc/containers/systemd` directory used for installed Quadlets. Treat manager access as privileged host administration.

Image: `ghcr.io/bryanconradhart/strix-halo-server-arcane-manager`

This image extends [single-purpose-os-arcane-manager](https://github.com/BryanConradHart/single-purpose-os/blob/main/variants/arcane-manager/README.md) with the Strix Halo hardware configuration, so the Arcane setup and administration instructions there apply unchanged.

Install this image using the shared [installation instructions](../../README.md), then complete the Arcane Manager setup below.

For a bare-metal installation, the [Butane setup builder](https://bryanconradhart.github.io/strix-halo-server/install/?variant=arcane-manager) lets you choose between the interactive setup after login (the default) and provisioning during installation. Choose Butane provisioning to make the Manager URL and encryption key choice required; the key can be generated in-browser or entered manually. Keep the generated Butane file private.

## Setup after first login

After installing the image and signing in, setup is offered automatically if it has not been completed. It configures the URL administrators will use to reach Arcane Manager.

The setup saves the URL and encryption key to `/etc/arcane/manager.env` (root-only). Back the file up together with Arcane's data: if the key is lost, existing manager data becomes inaccessible. Never change the key once set — existing data cannot be re-encrypted.

Open the configured URL (direct access is `http://<host>:3552`) and sign in as `arcane`. Arcane generates the initial password on first start and writes it to `initial-admin-password` inside its data volume, then requires a new password at first login:

```bash
sudo podman exec arcane-manager cat /app/data/initial-admin-password
```

Restrict access to trusted administrators; use HTTPS through a reverse proxy when accessing the manager remotely.

If you change the URL later, edit `ARCANE_APP_URL` in `/etc/arcane/manager.env` with `sudoedit`, then restart the manager:

```bash
sudo systemctl restart arcane-manager.service
```

Do not rerun the setup script after setup: it generates a new encryption key, which can make existing manager data inaccessible.

The manager's data and projects persist across operating-system updates.

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
