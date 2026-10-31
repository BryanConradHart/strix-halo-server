# Strix Halo Server

Preconfigured lightweight bootc-based Linux images for AMD Strix Halo systems, published to GHCR.

## Available images

| Variant | Image | Description |
| --- | --- | --- |
| Base | `ghcr.io/bryanconradhart/strix-halo-server` | A clean Strix Halo platform image with shared hardware configuration, Mesa Vulkan drivers, and hardware inspection tools. See the [base image README](variants/base/README.md) for installation and use. |
| Arcane | `ghcr.io/bryanconradhart/strix-halo-server-arcane` | The base platform plus Arcane Direct Agent for managing containers remotely. See the [Arcane image README](variants/arcane/README.md) for installation, enrollment, and use.

## Project goals

This project provides a lightweight, reproducible platform for Strix Halo systems, especially for local AI, inference, development, and self-hosted compute. Optional variants make common additions straightforward while keeping workload toolchains and custom services out of the clean base image.

For custom images, start from the published variant closest to your use case, add only the required packages and configuration, and publish it under your own image name.
