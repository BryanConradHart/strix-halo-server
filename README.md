# Strix Halo Server

Preconfigured lightweight bootc-based Linux images for AMD Strix Halo systems, published to GHCR.

## Available images

| Variant | Image | Description |
| --- | --- | --- |
| Base | `ghcr.io/bryanconradhart/strix-halo-server` | A clean Strix Halo platform image with shared hardware configuration, Mesa Vulkan drivers, and hardware inspection tools. See the [base image README](variants/base/README.md) for installation and use. |
| Arcane | `ghcr.io/bryanconradhart/strix-halo-server-arcane` | The base platform plus Arcane Direct Agent for managing containers remotely. See the [Arcane image README](variants/arcane/README.md) for installation, enrollment, and use. |
| Arcane Edge | `ghcr.io/bryanconradhart/strix-halo-server-arcane-edge` | The base platform plus Arcane Edge Agent for hosts that connect outbound to Arcane Manager. See the [Arcane Edge README](variants/arcane-edge/README.md) for installation and enrollment. |
| Arcane Manager | `ghcr.io/bryanconradhart/strix-halo-server-arcane-manager` | The base platform plus Arcane Manager for administering local and remote container environments. See the [Arcane Manager README](variants/arcane-manager/README.md) for installation and setup. |
| AI Toolbox Cockpit | `ghcr.io/bryanconradhart/strix-halo-server-ai-toolbox-cockpit` | The base platform plus an interactive terminal app for managing AI toolboxes, models, and inference servers. See the [AI Toolbox Cockpit README](variants/ai-toolbox-cockpit/README.md) for installation and use. |
| Lemonade | `ghcr.io/bryanconradhart/strix-halo-server-lemonade` | The base platform plus Lemonade Server for local AI APIs with AMD GPU support. See the [Lemonade README](variants/lemonade/README.md) for installation, first boot, and use. |

## Project goals

This project provides a lightweight, reproducible platform for Strix Halo systems, especially for local AI, inference, development, and self-hosted compute. Optional variants make common additions straightforward while keeping workload toolchains and custom services out of the clean base image.

For custom images, start from the published variant closest to your use case, add only the required packages and configuration, and publish it under your own image name.
