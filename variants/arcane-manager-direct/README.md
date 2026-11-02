# Strix Halo Server (Arcane Direct Agent)

This image adds the Arcane Direct Agent to the clean Strix Halo image and connects it to an Arcane Manager. Arcane can manage containers on this host through its Podman socket. Access to that socket is highly privileged, so expose the agent only on a trusted network and restrict access to TCP port `3553`.

The existing image reference retains its historical `arcane-manager-direct` name for compatibility:
`ghcr.io/bryanconradhart/strix-halo-server-arcane-manager-direct`

For installation, follow the shared instructions in the [root README](../../README.md). Complete the Arcane Direct Agent enrollment below after installing.

## First boot enrollment

1. In Arcane Manager, add a **Direct** environment for this host and note the generated `AGENT_TOKEN` and `MANAGER_API_URL`. The Manager URL should be reachable by the agent host.
2. Install and boot this image using one of the options above. On first boot, the system asks for the Manager URL and token through the system password prompt. Enter the values from Arcane; the token is not echoed.
3. The image writes the values to `/etc/arcane/agent.env` with root-only access, starts the agent, and persists the data volume. The enrollment prompt is skipped on subsequent boots.

The first-boot prompt requires a console/password prompt agent. If enrollment is skipped or times out, it is offered again at the next boot. If the agent cannot connect after enrollment, check the URL, port, firewall, and Arcane environment configuration.

The token remains machine-specific host configuration: it is not included in the repository or image and is preserved across bootc updates. Back it up in a password manager or secret manager for disaster recovery. Protect the Manager-generated token and `/etc/arcane/agent.env`; rotate the token if compromised.

## Updates and recovery

Upgrade the OS image with bootc:

```bash
sudo bootc status
sudo bootc upgrade
sudo systemctl reboot
```

For a specific image build, switch to its versioned tag:

```bash
sudo bootc switch --transport registry ghcr.io/bryanconradhart/strix-halo-server-arcane-manager-direct:vYYYY.MM.DD-HHMMSS-rRUN_NUMBER
sudo systemctl reboot
```

Each build publishes a `latest` tag and a versioned tag in the form `vYYYY.MM.DD-HHMMSS-rRUN_NUMBER`. See the [published image page](https://github.com/BryanConradHart/strix-halo-server/pkgs/container/strix-halo-server-arcane-manager-direct) for available tags. The host's daily Podman auto-update timer checks the agent's `latest` image and restarts the Quadlet when an updated image is available. You can also update the environment through Arcane's controls. Update the operating system image separately with `bootc upgrade`. For clean recovery, install the same image variant, create or restore the Arcane environment, then enter its token at the first-boot prompt.

Arcane manages containers through Podman's Docker-compatible API. It does not manage arbitrary host systemd services. See Arcane's [remote environment documentation](https://getarcane.app/docs/remote/environments) for Direct Agent networking and environment setup.
