# Project Specification

This repository defines easy-to-maintain, easy-to-deploy bootable images for AMD Strix Halo systems, with 128 GB memory configurations as the primary target. It publishes a clean base image and a small set of optional, targeted image variants. The root [README.md](README.md) catalogs the images and links to variant-specific installation and administration instructions.

## Product requirements

- Provide a reproducible, bootable system suited to local AI, inference, development, and self-hosted compute workloads on Strix Halo hardware.
- Keep the base image lightweight, clean, predictable, and maintainable over time. Do not turn it into a workload-specific appliance; workload toolchains and custom services should remain optional variants.
- Build every image variant directly from the same uCore base and shared Strix configuration. Do not make a published variant a build prerequisite for another variant; build variants in parallel from the same source revision.
- Keep variant-specific recipes, assets, and documentation together under `variants/<name>/`. Keep configuration common to all variants in a shared location, with one source of truth.
- Enable uCore's rootful `podman-restart.service` in shared configuration so rootful Podman containers with an `always` restart policy restart at boot in every variant.
- For rootful Quadlet services intended to track registry tags, set `AutoUpdate=registry` and enable `podman-auto-update.timer` in the variant; container image updates are separate from bootc OS updates.
- Give each published image a distinct, identifiable name and provide a variant-specific README linked from the root README.
- Provide assets optimized for 128 GB Strix Halo systems. Support for other Strix Halo memory configurations is not a requirement.
- Treat ease of adoption and maintenance as a product requirement: installing and keeping this image updated must be easier than manually reproducing its kernel arguments, hardware configuration, and software setup on an existing Linux homelab server. Provide at least one documented, repeatable installation path that applies the image's configuration without asking users to recreate recipe steps by hand, and support routine updates without repeating installation. uCore and Butane/Ignition are acceptable when the complete workflow remains straightforward. Never bake machine-specific credentials into the image. Keep workload-specific additions optional.
- Document separate paths for an already provisioned bootc-managed host and a clean bare-metal installation. For bare metal, let users run a small host-side helper from the Fedora CoreOS live environment to prepare Ignition and install in one session; reuse uCore's supported Butane/Ignition bootstrap, make SSH key login optional, and do not require users to author the full configuration or maintain project-specific target-side provisioning scripts or services.

## Deployment and lifecycle requirements

- Support a straightforward clean bare-metal installation through uCore's Fedora CoreOS and Butane/Ignition first-install workflow, followed by switching to the selected project image. Do not present direct bootc disk installation or a locally generated image ISO as a complete first-install path unless it also provisions a usable login account. Do not generate or publish installer ISOs or create GitHub Releases in CI; publish identifiable container image tags instead.
- Document the bootc and bare-metal installation paths in the root README and link to them from every variant README. Do not present WSL as a tested bare-metal installation environment.
- Make routine updates reliable and low-effort, without requiring users to repeat the initial installation process.
- Make container image tags reproducible and identifiable for every variant. Users should be able to follow the latest image or select a specific version for repeatable deployment.
- Keep deployment and update behavior consistent across supported installation paths, and update the README and this specification when those user-facing workflows change.

## Change and validation guidelines

- Prefer changes that reduce operational complexity and keep the base image and variants maintainable.
- Keep additions aligned with the base-platform scope; avoid adding optional workload stacks to the default image.
- Validate every image recipe in CI and publish all variants from the build workflow. Keep builds independent and parallel; CI must not generate installer ISOs. Stage shared BlueBuild file assets into each variant's build context before validation and publishing.
- Keep credentials and machine-specific secrets out of recipes, source files, image builds, and published images. Provision secrets on the installed host.
- Validate changes against the requirements they affect, especially hardware compatibility, installation, updates, and reproducibility. Update root and variant-specific documentation when their workflows change.
- Update related user-facing documentation when behavior or supported workflows change.
