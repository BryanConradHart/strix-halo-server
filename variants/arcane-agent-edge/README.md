# Strix Halo Server (Arcane Agent Edge)

This image adds the Arcane Edge Agent to the clean Strix Halo image. The agent connects outbound to Arcane Manager, so the host does not need an inbound agent port. The Podman socket gives the manager control over containers on this host; use a trusted Arcane Manager and protect its credentials.

Image: `ghcr.io/bryanconradhart/strix-halo-server-arcane-agent-edge`

Install this image using the shared [installation instructions](../../README.md), then enroll the Edge Agent as described below.

For a bare-metal installation, the [Butane setup builder](https://bryanconradhart.github.io/strix-halo-server/install/?variant=arcane-agent-edge) lets you choose between the interactive setup after login (the default) and provisioning during installation. Choose Butane provisioning to require the Edge Agent token and Manager API URL. Keep the generated Butane file private.

## Enrollment after first login

In Arcane Manager, add an **Edge** environment and generate the agent configuration. After installing the image and signing in, enrollment is offered automatically if it has not been completed. The token is stored only in `/etc/arcane/agent.env` on the host, with root-only access; it is not included in the image.

If you deferred enrollment, run it manually with:

```bash
sudo /usr/libexec/arcane-edge-enroll.sh
```

To replace the token or Manager URL, stop the agent, back up the current credentials, and run:

```bash
sudo systemctl stop arcane-edge-agent.service
sudo mv /etc/arcane/agent.env /etc/arcane/agent.env.backup
sudo /usr/libexec/arcane-edge-enroll.sh
```

The login setup offer appears only when `/etc/arcane/agent.env` is missing. Running the enrollment command manually replaces the file even if it already exists. Keep the backup private because it contains the token.

If the agent cannot connect, check the Manager URL, outbound network access, and Arcane environment configuration.

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
