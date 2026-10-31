# Project Specification

This repository defines easy-to-maintain, easy-to-deploy bootable images for AMD Strix Halo systems, with 128 GB memory configurations as the primary target. It publishes a clean base image and a small set of optional, targeted image variants. The root [README.md](README.md) catalogs the images and links to variant-specific installation and administration instructions.

## Product requirements

- Provide a reproducible, bootable system suited to local AI, inference, development, and self-hosted compute workloads on Strix Halo hardware.
- Keep the base image lightweight, clean, predictable, and maintainable over time. Do not turn it into a workload-specific appliance; workload toolchains and custom services should remain optional variants.
- Build every image variant directly from the same uCore base and shared Strix configuration. Do not make a published variant a build prerequisite for another variant; build variants in parallel from the same source revision.
- Keep variant-specific recipes, assets, and documentation together under `variants/<name>/`. Keep configuration common to all variants in a shared location, with one source of truth.
- Enable uCore's rootful `podman-restart.service` in shared configuration so rootful Podman containers with an `always` restart policy restart at boot in every variant.
- Give each published image a distinct, identifiable name and provide a variant-specific README linked from the root README.
- Provide assets optimized for 128 GB Strix Halo systems. Support for other Strix Halo memory configurations is not a requirement.
- Make it straightforward to extend the system with workload-specific software, configuration, and services without complicating the default installation.

## Deployment and lifecycle requirements

- Support a straightforward clean installation on bare-metal Strix Halo systems through bootc installation or an ISO users can build from the published image with the BlueBuild CLI. Do not generate or publish installer ISOs or create GitHub Releases in CI; publish identifiable container image tags instead.
- Document three installation options in each variant README: switch directly from a bootc-managed system; boot a Linux live USB and run the target image's installer in Podman for a clean-disk installation; or build and install an ISO locally from the published image. The root README catalogs variants and links to their installation instructions; do not present WSL as a tested bare-metal installation environment.
- Make routine updates reliable and low-effort, without requiring users to repeat the initial installation process.
- Make container image tags reproducible and identifiable for every variant. Users should be able to follow the latest image or select a specific version for repeatable deployment.
- Keep deployment and update behavior consistent across supported installation paths, and update the README and this specification when those user-facing workflows change.

## Change and validation guidelines

- Prefer changes that reduce operational complexity and keep the base image and variants maintainable.
- Keep additions aligned with the base-platform scope; avoid adding optional workload stacks to the default image.
- Validate every image recipe in CI and publish all variants from the build workflow. Keep builds independent and parallel; CI must not generate installer ISOs.
- Keep credentials and machine-specific secrets out of recipes, source files, image builds, and published images. Provision secrets on the installed host.
- Validate changes against the requirements they affect, especially hardware compatibility, installation, updates, and reproducibility. Update root and variant-specific documentation when their workflows change.
- Update related user-facing documentation when behavior or supported workflows change.
