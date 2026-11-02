# Strix Halo Server (AI Toolbox Cockpit)

This image packages [AI Toolbox Cockpit](https://github.com/kyuz0/ai-toolbox-cockpit), an interactive terminal app authored by [kyuz0](https://github.com/kyuz0) for managing AI toolboxes, models, and local inference servers. The app supports Strix Halo in its platform catalog and uses Podman and Distrobox for its container workflows.

Image: `ghcr.io/bryanconradhart/strix-halo-server-ai-toolbox-cockpit`

For installation, follow the shared instructions in the [root README](../../README.md). After installing, see [Use](#use) to start AI Toolbox Cockpit.

## Use

After signing in, run:

```bash
ai-toolbox-cockpit
```

The app is installed from a pinned upstream revision and uses the signed-in user's Podman account to create and run toolboxes. See the [upstream AI Toolbox Cockpit project](https://github.com/kyuz0/ai-toolbox-cockpit), authored by [kyuz0](https://github.com/kyuz0), for supported backends, models, and controls.

## Updates

Update the operating system image with bootc:

```bash
sudo bootc upgrade
sudo systemctl reboot
```

To pin a specific build, switch to its versioned image tag:

```bash
sudo bootc switch --transport registry ghcr.io/bryanconradhart/strix-halo-server-ai-toolbox-cockpit:vYYYY.MM.DD-HHMMSS-rRUN_NUMBER
sudo systemctl reboot
```

See the [published image page](https://github.com/BryanConradHart/strix-halo-server/pkgs/container/strix-halo-server-ai-toolbox-cockpit) for available tags. The Cockpit app version changes when this image recipe is updated to a newer upstream revision.
