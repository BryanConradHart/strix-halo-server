# Project Specification

This repository defines an easy-to-maintain, easy-to-deploy, lightweight compute server for AMD Strix Halo systems, with 128 GB memory configurations as the primary target. See [README.md](README.md) for user-facing installation and administration instructions.

## Product requirements

- Provide a reproducible, bootable system suited to local AI, inference, development, and self-hosted compute workloads on Strix Halo hardware.
- Keep the base system lightweight, clean, predictable, and maintainable over time. Do not turn it into a workload-specific appliance; workload toolchains and custom services should remain optional.
- Provide assets optimized for 128 GB Strix Halo systems. Support for other Strix Halo memory configurations is not a requirement.
- Make it straightforward to extend the system with workload-specific software, configuration, and services without complicating the default installation.

## Deployment and lifecycle requirements

- Support a straightforward clean installation on bare-metal Strix Halo systems, as well as a practical path to deploy or update an existing installation.
- Make routine updates reliable and low-effort, without requiring users to repeat the initial installation process.
- Make releases reproducible and identifiable. Users should be able to follow the current release or select a specific version for repeatable deployment.
- Keep deployment and update behavior consistent across supported installation paths, and update the README when those user-facing workflows change.

## Change and validation guidelines

- Prefer changes that reduce operational complexity and keep the base image maintainable.
- Keep additions aligned with the base-platform scope; avoid adding optional workload stacks to the default image.
- Validate changes against the requirements they affect, especially hardware compatibility, installation, updates, and reproducibility.
- Update related user-facing documentation when behavior or supported workflows change.
