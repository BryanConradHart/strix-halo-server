# Strix Halo Server (Arcane Agent)

This image adds the Arcane agent to the clean Strix Halo image. The agent connects outbound to Arcane Manager, so the host does not need an inbound agent port. The Podman socket gives the manager control over containers on this host; use a trusted Arcane Manager and protect its credentials.

The agent also mounts the host system D-Bus socket to control rootful systemd services, and shares the writable `/etc/containers/systemd` directory where Podman installs Quadlets.

Image: `ghcr.io/bryanconradhart/strix-halo-server-arcane-agent`

This image extends [single-purpose-os-arcane-agent](https://github.com/BryanConradHart/single-purpose-os/blob/main/variants/arcane-agent/README.md) with the Strix Halo hardware configuration, so the Arcane enrollment and administration instructions there apply unchanged.

## Install

On a system already managed by bootc, switch to this image and reboot:

```bash
sudo bootc switch --transport registry ghcr.io/bryanconradhart/strix-halo-server-arcane-agent:latest
sudo systemctl reboot
```

For a clean installation on new hardware, boot a live environment such as the [Fedora Workstation Live image](https://fedoraproject.org), connect to the network, and install the image directly onto the target drive. Identify the drive with `lsblk -o NAME,SIZE,MODEL,TYPE,MOUNTPOINTS` — the command below erases it, so double-check the device path and do not select the live USB:

```bash
sudo podman run --rm --privileged --pid=host \
  -v /var/lib/containers:/var/lib/containers \
  -v /dev:/dev \
  --security-opt label=type:unconfined_t \
  ghcr.io/bryanconradhart/strix-halo-server-arcane-agent:latest \
  bootc install to-disk --wipe --generic-image /dev/REPLACE_WITH_TARGET_DISK
```

Reboot, then sign in as `core` with the temporary password `core` and choose a new password. For a headless install, mount your public key into the container with `-v "$HOME/.ssh/id_ed25519.pub:/tmp/key.pub:ro"` and add `--root-ssh-authorized-keys /tmp/key.pub` to the install command; the key authorizes root, and first boot also installs it for `core`. See the root [installation instructions](../../README.md) for the full details.

## Install with customization

A drop-in can be applied to a running system, or during a bare-metal install as shown below, where it is active from the first boot. Write one with any editor, anywhere — say `~/20-custom.conf` — then run the bare-metal install command above and, before rebooting, copy your files into the installed system:

```bash
sudo mkdir -p /mnt/newroot
sudo mount /dev/REPLACE_WITH_ROOT_PARTITION /mnt/newroot
sudo install -D -m 0644 ~/20-custom.conf \
  /mnt/newroot/sysroot/ostree/deploy/*/deploy/*.0/etc/containers/systemd/arcane-agent.container.d/20-custom.conf
# Only if your drop-in references an env file (see "Provide the token yourself"):
sudo install -D -m 0600 ~/agent-user.env \
  /mnt/newroot/sysroot/ostree/deploy/*/deploy/*.0/etc/arcane/agent-user.env
sudo umount /mnt/newroot
```

Each example below is a snippet of `20-custom.conf`; combine the ones you want into that single file. On login, enrollment asks for any required values you haven't supplied.

**Change the Manager URL:**

```ini
# 20-custom.conf
[Container]
Environment=ARCANE_MANAGER_API_URL=https://arcane.example.com
```

**Provide the token yourself**, for example to rotate it. Keep it out of the drop-in — inline values are visible to any local user — by referencing an env file. Create `~/agent-user.env` containing `ARCANE_AGENT_TOKEN=arc_…`; the install command above copies it root-only alongside the drop-in (the service won't start if the file is missing):

```ini
# 20-custom.conf
[Container]
EnvironmentFile=/etc/arcane/agent-user.env
```

**Give the agent more time or memory before it restarts:**

```ini
# 20-custom.conf
[Service]
RestartSec=30s
MemoryMax=2G
```

Merge rules — how settings combine and how to clear a list — are in the [customization guide](../../README.md#customizing-services-with-quadlet-drop-ins). Never copy the whole shipped unit into `/etc` to edit it: the copy blocks all future updates to the service.

## Enrollment after first login

In Arcane Manager, add a remote (Edge) environment and generate the agent configuration. After installing the image and signing in, enrollment is offered automatically if it has not been completed. The token is stored only in `/etc/arcane/agent.env` on the host, with root-only access; it is not included in the image.

The offer appears whenever enrollment is incomplete: `/etc/arcane/agent.env` is missing, or a required value is set neither in that file nor by a drop-in. If you supplied every required value through a drop-in during [Install with customization](#install-with-customization), enrollment is skipped and the agent starts on boot. Otherwise it asks only for the values you left out.

If you deferred enrollment, run it manually with:

```bash
sudo /usr/libexec/arcane-agent-enroll.sh
```

To replace the token or Manager URL, stop the agent, back up the current credentials, and run:

```bash
sudo systemctl stop arcane-agent.service
sudo mv /etc/arcane/agent.env /etc/arcane/agent.env.backup
sudo /usr/libexec/arcane-agent-enroll.sh
```

Running the enrollment command manually replaces the file even if it already exists. Keep the backup private because it contains the token. If the agent cannot connect, check the Manager URL, outbound network access, and Arcane environment configuration.

## Updates

Update the operating system image with bootc:

```bash
sudo bootc upgrade
sudo systemctl reboot
```

To pin a specific build, switch to its versioned image tag:

```bash
sudo bootc switch --transport registry ghcr.io/bryanconradhart/strix-halo-server-arcane-agent:vYYYY.MM.DD-HHMMSS-rRUN_NUMBER
sudo systemctl reboot
```

The host's daily Podman auto-update timer checks the agent's `latest` image and restarts the Quadlet when an updated image is available. You can also update the environment through Arcane Manager. Update the operating system image separately with `bootc upgrade`. See the [published image page](https://github.com/BryanConradHart/strix-halo-server/pkgs/container/strix-halo-server-arcane-agent) for available tags and the [Arcane agents guide](https://getarcane.app/docs/remote/agents) for agent configuration.
