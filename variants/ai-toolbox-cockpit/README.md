# Strix Halo Server (AI Toolbox Cockpit)

This image packages [AI Toolbox Cockpit](https://github.com/kyuz0/ai-toolbox-cockpit), an interactive terminal app authored by [kyuz0](https://github.com/kyuz0) for managing AI toolboxes, models, and local inference servers. The app supports Strix Halo in its platform catalog and uses Podman and Distrobox for its container workflows.

Image: `ghcr.io/bryanconradhart/strix-halo-server-ai-toolbox-cockpit`

Install this image using the shared [installation instructions](../../README.md). There is no first-boot enrollment or host-wide setup; start the app from the signed-in user's shell as shown below.

## Use

After signing in, run:

```bash
ai-toolbox-cockpit
```

The app is installed from the latest upstream revision available when the image is built and uses the signed-in user's Podman account to create and run toolboxes. Run `ai-toolbox-cockpit` again whenever you want to reopen it; no setup script needs to be rerun. Each published image tag identifies the app version included in that build. See the [upstream AI Toolbox Cockpit project](https://github.com/kyuz0/ai-toolbox-cockpit), authored by [kyuz0](https://github.com/kyuz0), for supported backends, models, and controls.

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

See the [published image page](https://github.com/BryanConradHart/strix-halo-server/pkgs/container/strix-halo-server-ai-toolbox-cockpit) for available tags. New image builds install the latest upstream Cockpit revision available at build time.
