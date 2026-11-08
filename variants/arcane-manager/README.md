# Strix Halo Server (Arcane Manager)

This image adds Arcane Manager for administering local and remote container environments. It exposes the manager web interface on TCP port `3552` and connects to the host's Podman service. Access to the Podman socket allows full control of containers on the host; restrict access to trusted administrators and networks.

Image: `ghcr.io/bryanconradhart/strix-halo-server-arcane-manager`

Install this image using the shared [installation instructions](../../README.md), then complete the Arcane Manager setup below.

For a bare-metal installation, you can enter the Manager URL and choose to generate or manually enter its encryption key in the [Butane setup builder](https://bryanconradhart.github.io/strix-halo-server/install/?variant=arcane-manager). Keep the generated Butane file private.

## Setup after first login

After installing the image and signing in, setup is offered automatically if it has not been completed. It configures the URL administrators will use to reach Arcane Manager.

The setup creates an encryption key and saves it with the URL in `/etc/arcane/manager.env`, a root-only host file. Back up this file together with Arcane's data. The login offer is suppressed if the file exists.

Open the configured URL (direct access is `http://<host>:3552`), sign in with the initial credentials `arcane` / `arcane-admin`, and change the password. Restrict access to trusted administrators; use HTTPS through a reverse proxy when accessing the manager remotely.

If you need to change the URL after setup, edit `APP_URL` in `/etc/arcane/manager.env` with `sudoedit`, keep the existing `ENCRYPTION_KEY` unchanged, then restart the manager:

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

See the [published image page](https://github.com/BryanConradHart/strix-halo-server/pkgs/container/strix-halo-server-arcane-manager) for available tags. Arcane Manager's container image is checked and updated by Podman's automatic update service. See the [Arcane installation guide](https://getarcane.app/docs/get-started/installation) and [remote environment guide](https://getarcane.app/docs/remote/environments) for administration and agent setup.
