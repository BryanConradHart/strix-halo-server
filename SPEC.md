# Specification

This repository defines easy-to-maintain, easy-to-deploy bootable images for AMD Strix Halo systems, with 128 GB memory configurations as the primary target. It publishes a clean base image and a small set of optional, targeted image variants. The root [README.md](README.md) catalogs the images and links to variant-specific installation and administration instructions. The *why* behind these requirements lives in [DECISIONS.md](DECISIONS.md).

Requirements are grouped by topic; keep closely related requirements together when adding or editing.

## Functional requirements

### Images and variants

- Provide a reproducible, bootable system suited to local AI, inference, development, and self-hosted compute workloads on Strix Halo hardware.
- Keep the base image lightweight, clean, predictable, and maintainable over time. Do not turn it into a workload-specific appliance; workload toolchains and custom services should remain optional variants.
- Build every image variant from the published [single-purpose-os-base](https://github.com/BryanConradHart/single-purpose-os) image (directly, or through a published single-purpose-os variant) plus the shared Strix configuration; build variants in parallel from the same source revision, never making one variant in this repository a build prerequisite for another. The Arcane variants extend the published [single-purpose-os](https://github.com/BryanConradHart/single-purpose-os) Arcane images and add only the shared Strix hardware configuration ([decision 0002](DECISIONS.md)).
- Keep variant-specific recipes, assets, and documentation together under `variants/<name>/`. Keep configuration common to all variants in a shared location, with one source of truth.
- Give each published image a distinct, identifiable name and provide a variant-specific README linked from the root README.
- Provide assets optimized for 128 GB Strix Halo systems. Support for other Strix Halo memory configurations is not a requirement.

### Service deployment

- Enable uCore's rootful `podman-restart.service` in shared configuration so rootful Podman containers with an `always` restart policy restart at boot in every variant.
- For rootful Quadlet services intended to track registry tags, set `AutoUpdate=registry` and enable `podman-auto-update.timer` in the variant; container image updates are separate from bootc OS updates.
- Prefer deploying application workloads as Podman Quadlet units shipped in the image at `/usr/share/containers/systemd/`.
- Base each container unit on the upstream application's official Podman installation instructions (for example, Arcane's Podman setup guide) and express them as a Quadlet following `podman-systemd.unit(5)`; keep the unit in sync with upstream changes and link to them from the variant README.
- systemd should be what starts services. Prefer Quadlet over compose runtimes (docker-compose, podman-compose) and other container lifecycle managers; when Quadlet is a poor fit, podman-compose or docker compose is acceptable (a Quadlet `.compose` unit preferred), started by systemd at boot with its restart policy honored.
- Design image-shipped units to be customizable via official Quadlet drop-ins without editing the image unit. Bake non-secret stable defaults as `Environment=` (drop-ins override per variable); keep secrets and machine-specific values in an `EnvironmentFile` ([decision 0001](DECISIONS.md)). Keep machine-specific settings (bind mounts, extra devices, non-default ports, tunable resource limits) out of image units where a reasonable default exists, and document each supported customization's drop-in path and contents in the variant README.
- Quadlet list keys like `Volume=` accumulate across drop-ins and an empty value resets them; `Environment=` merges per variable. Never instruct users to copy a whole image unit into `/etc` as an override: the copy shadows the image unit and blocks its future updates.
- Enrollment and setup scripts must create an editable default drop-in for common machine-local settings, and must detect settings already supplied by user drop-ins (merged values from `/etc` and `/run` drop-in directories) instead of prompting for or overwriting them.

### Installation

- Support installation onto an existing bootc system with `bootc switch`, and clean bare-metal installation that boots a live environment and installs the selected image with `bootc install to-disk`, ending on that image without a follow-up switch ([decision 0003](DECISIONS.md)). Any bare-metal path must leave a usable login account on first boot.
- After a bare-metal install, signing in leads to the variant's interactive first-login setup; interactive setup is the default and only documented way to apply machine-specific values and credentials. Do not require a provisioning service or pre-authored configuration files.
- Let users add Quadlet drop-ins during installation: the docs show how to place a drop-in file into the installed system's `/etc` before the first reboot so it is active from first boot.
- Do not generate or publish installer ISOs or create GitHub Releases in CI; publish identifiable container image tags instead.
- Document both installation paths in the root README and link to them from every variant README. Do not present WSL as a tested bare-metal installation environment.

### Updates and lifecycle

- Make routine updates reliable and low-effort, without requiring users to repeat the initial installation process.
- Quadlet drop-ins and other configuration under `/etc` are machine-local state and must survive `bootc upgrade` and `bootc switch`; do not rely on anything written under `/usr` persisting across an image update, and do not write machine-specific state into image units.
- Keep deployment and update behavior consistent across supported installation paths, and update the README and this specification when those user-facing workflows change.

## Non-functional requirements

### Ease of adoption and maintenance

- Installing and keeping this image updated must be easier than manually reproducing its kernel arguments, hardware configuration, and software setup on an existing Linux homelab server. Provide at least one documented, repeatable installation path that applies the image's configuration without asking users to recreate recipe steps by hand, and support routine updates without repeating installation. Keep workload-specific additions optional.
- Prefer changes that reduce operational complexity and keep the base image and variants maintainable. Keep additions aligned with the base-platform scope; avoid adding optional workload stacks to the default image.

### Security

- Never bake machine-specific credentials into the image. Keep credentials and machine-specific secrets out of recipes, source files, image builds, and published images; provision secrets on the installed host.

### Reproducibility

- Make container image tags reproducible and identifiable for every variant. Users should be able to follow the latest image or select a specific version for repeatable deployment.

### Validation

- Validate every image recipe in CI and publish all variants from the build workflow. Keep builds independent and parallel; CI must not generate installer ISOs. Stage shared BlueBuild file assets into each variant's build context before validation and publishing.
- Validate changes against the requirements they affect, especially hardware compatibility, installation, updates, and reproducibility.
- Update root and variant-specific documentation when behavior or supported workflows change.
