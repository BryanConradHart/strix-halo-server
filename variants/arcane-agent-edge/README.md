# Strix Halo Server (Arcane Agent Edge)

This image adds the Arcane Edge Agent to the clean Strix Halo image. The agent connects outbound to Arcane Manager, so the host does not need an inbound agent port. The Podman socket gives the manager control over containers on this host; use a trusted Arcane Manager and protect its credentials.

Image: `ghcr.io/bryanconradhart/strix-halo-server-arcane-agent-edge`

For installation, follow the shared instructions in the [root README](../../README.md). Complete the Arcane Edge Agent enrollment below after installing.

## First boot enrollment

In Arcane Manager, add an **Edge** environment and generate the agent configuration. On first boot, enter the Manager URL and generated agent token when prompted. The token is stored only in a root-only file on the host and is not included in the image. If enrollment is skipped or times out, it is offered again at the next boot.

## Updates

Update the operating system image with bootc:

```bash
sudo bootc upgrade
sudo systemctl reboot
```

To pin a specific build, switch to its versioned image tag:

```bash
sudo bootc switch --transport registry ghcr.io/bryanconradhart/strix-halo-server-arcane-agent-edge:vYYYY.MM.DD-HHMMSS-rRUN_NUMBER
sudo systemctl reboot
```

The host's daily Podman auto-update timer checks the agent's `latest` image and restarts the Quadlet when an updated image is available. You can also update the environment through Arcane Manager. Update the operating system image separately with `bootc upgrade`. See the [published image page](https://github.com/BryanConradHart/strix-halo-server/pkgs/container/strix-halo-server-arcane-agent-edge) for available tags and the [Arcane Edge documentation](https://getarcane.app/docs/remote/environments) for network and environment setup.
