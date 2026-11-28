# Decisions

The reasoning behind choices in [SPEC.md](SPEC.md). When editing the spec, do not violate these decisions; when a spec change conflicts with one, ask the user whether to change the spec or the decision.

Decisions are numbered and grouped by the spec topic they support; keep related decisions adjacent and reference them from the requirements they justify.

Record only non-obvious choices: the alternatives considered, the tradeoffs, and why the rejected options were rejected — the things someone would get wrong or undo without this file. Obvious choices and routine design decisions don't belong here.

## 0001. Machine-specific values and secrets use `EnvironmentFile`, not `Environment=`

### Context

Quadlet `Environment=` keys merge per variable across drop-ins, which makes them look like a convenient place for any value: a drop-in could override a single variable without touching the rest. We still keep secrets and machine-specific values out of image units and drop-ins, in a root-only `EnvironmentFile` instead.

### Decision

Image units bake only non-secret stable defaults as `Environment=`. Setup scripts write machine-specific values (URLs, tokens, API keys, encryption keys) to a `0600` root-only `EnvironmentFile` referenced by the image unit.

### Rationale

- The Quadlet generator translates `Environment=NAME=VALUE` into `--env NAME=VALUE` arguments on the generated service's `ExecStart`. Those values are visible to any local user via `systemctl cat`, `systemctl show -p ExecStart`, `ps`, and `/proc/<pid>/cmdline`. `EnvironmentFile=` puts only the file path on the command line; values stay in the root-only file.
- The env file's existence is the setup-complete signal: units gate on `ConditionPathExists=` and the login offer checks the same file. A file is a clean boolean; drop-ins are user customization territory where existence is ambiguous.
- Ownership separation: setup rewrites the env file wholesale, so it is safe to regenerate; user overrides use the systemd layering mechanism instead. A non-secret override is a single `Environment=` line in a `20-` drop-in, since podman applies `--env` after `--env-file` and inline values therefore win per variable. Only secret overrides need the heavier form — a user-owned env file referenced by the drop-in, where later-`EnvironmentFile` precedence makes it win. The env-file indirection exists solely to keep values out of `ExecStart`, so it is not applied to values with no confidentiality requirement.

## 0002. Arcane variants build on the published single-purpose-os images

### Context

The repository rule is that every variant builds from a published base in parallel, with no variant depending on another build in the same repository. The Arcane manager/agent variants need both the Arcane service stack and the Strix hardware configuration, and the same service stack is useful on non-Strix hardware.

### Decision

The Arcane variants extend the published [single-purpose-os](https://github.com/BryanConradHart/single-purpose-os) images (`single-purpose-os-arcane-manager`, `single-purpose-os-arcane-agent`) and add only the shared Strix hardware configuration.

### Rationale

- The base images are published by a different repository, so this does not create an intra-repository build prerequisite or ordering problem; the strix build pipeline never has to build them first.
- The service definitions live once, in single-purpose-os; the strix variants add hardware configuration only, avoiding drift between two copies of the same Quadlet units.

## 0003. Installation uses bootc only; no Butane/Ignition path

### Context

Bare-metal installation previously ran through a uCore Fedora CoreOS bootstrap configured with Butane/Ignition, including a graphical utility that generated Butane files and could provision variant setup values during install.

### Decision

Installation uses bootc alone: `bootc switch` on an existing bootc system, and `bootc install to-disk` from a live environment for bare metal. The Butane/Ignition path, the graphical builder utility, and its template are no longer documented or referenced. CI publishes container tags only; no installer ISOs or disk images are generated.

### Rationale

- `bootc install` applies the image's own configuration (kernel arguments, files) directly; installing via an ostree/Butane bootstrap and switching later did not reliably apply image-declared kargs.
- One installation mechanism removes the parallel provisioning surface: the builder utility duplicated what the interactive first-login setup and Quadlet drop-ins already do, and it required its own credential-handling requirements.
- Machine-local customization during install is covered by placing drop-in files into the installed system's `/etc` before first reboot; secrets are entered during first-login setup instead of being baked into a generated config file.
- The GitHub Pages site that once hosted the Butane builder now hosts per-variant drop-in generators, which assemble a `20-custom.conf` (and a root-only env file for secrets) for the same install-time placement; they run entirely in the browser and transmit nothing.
- Fedora's bootc docs treat bootc-image-builder disk images (ISO/raw/qcow2) as the more common provisioning path, but uCore has no interactive installer to boot, so a forked installer would be ours to build and maintain. Users who need machine images can run bootc-image-builder themselves; we don't publish or maintain those artifacts.

## 0004. Temporary `core` password, SSH key shared to `core` at first boot

### Context

Fedora bootc base images ship no default credentials: root exists with no password, and access is expected via injected SSH keys. Our audience installs homelab servers interactively and needs a console login out of the box. `bootc install --root-ssh-authorized-keys` can only write root's `authorized_keys` (it runs before any user exists).

### Decision

Images provision a `core` user (wheel/sudo) with the temporary password `core` and `chage -d 0`, forcing a password change at first login. A first-boot service copies root's `authorized_keys` to `core` (only when `core` has none), so a headless install key works for `core` as well as root.

### Rationale

- A console password is the simplest usable first login for interactive bare-metal installs; forced rotation means the well-known default is never a standing credential.
- Copying the installer key to `core` keeps headless installs working for the account that owns the home directory and setup flow, without inventing a new key-provisioning mechanism.
