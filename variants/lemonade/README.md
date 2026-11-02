# Strix Halo Server (Lemonade)

This image packages [Lemonade Server](https://lemonade-server.ai/), an upstream local AI server providing APIs for chat, coding, speech, image generation, and embeddings. It uses the AMD GPU devices and publishes the API on TCP port `13305`.

Image: `ghcr.io/bryanconradhart/strix-halo-server-lemonade`

For installation, follow the shared instructions in the [root README](../../README.md). Complete the Lemonade first-boot setup below after installing.

## First boot and use

Choose an API key of at least 32 letters, numbers, underscores, or hyphens at the first-boot prompt. The key is stored in a root-only file on the host, not in the image. Keep it available for clients that connect to `http://<host>:13305`; provide it as the client's API key. Model and server data persist across operating-system updates.

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
