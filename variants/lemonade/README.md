# Strix Halo Server (Lemonade)

This image packages [Lemonade Server](https://lemonade-server.ai/), an upstream local AI server providing APIs for chat, coding, speech, image generation, and embeddings. It uses the AMD GPU devices and publishes the API on TCP port `13305`.

Image: `ghcr.io/bryanconradhart/strix-halo-server-lemonade`

Install this image using the shared [installation instructions](../../README.md), then configure the Lemonade API key as described below.

For a bare-metal installation, the [Butane setup builder](https://bryanconradhart.github.io/strix-halo-server/install/?variant=lemonade) lets you choose between the interactive setup after login (the default) and provisioning during installation. Choose Butane provisioning to require the Lemonade API key. Keep the generated Butane file private.

## Setup after first login

After installing the image and signing in, setup is offered automatically if it has not been completed. The API key is stored in `/etc/lemonade/server.env` with root-only access; it is not included in the image. Keep it available for clients connecting to `http://<host>:13305`; provide it as the client's API key. Model and server data persist across operating-system updates.

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

See the [published image page](https://github.com/BryanConradHart/strix-halo-server/pkgs/container/strix-halo-server-lemonade) for available tags. The server container follows the upstream stable image and is updated by Podman's automatic update service. Consult the official [Lemonade Server documentation](https://lemonade-server.ai/docs/) for API use and model setup.
