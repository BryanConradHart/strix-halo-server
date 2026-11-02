#!/usr/bin/env bash
set -euo pipefail

image=${1:?Usage: prepare-install-ignition.sh <image-reference> [ssh-public-key-file]}
key_file=${2:-}
output=ucore-autorebase.ign

if [[ "$image" == IMAGE_FROM_TABLE || "$image" == IMAGE_FROM_TABLE:* ]]; then
  echo "No image selected. Replace IMAGE_FROM_TABLE with an image from the options in the README." >&2
  exit 2
fi

image_name=${image%%:*}
image_name=${image_name%%@*}
case "$image_name" in
  ghcr.io/bryanconradhart/strix-halo-server|\
  ghcr.io/bryanconradhart/strix-halo-server-arcane-manager|\
  ghcr.io/bryanconradhart/strix-halo-server-arcane-agent-edge|\
  ghcr.io/bryanconradhart/strix-halo-server-arcane-manager-direct|\
  ghcr.io/bryanconradhart/strix-halo-server-ai-toolbox-cockpit|\
  ghcr.io/bryanconradhart/strix-halo-server-lemonade)
    ;;
  *)
    echo "Image not recognized: $image. Check the available image options in the README." >&2
    exit 2
    ;;
esac

if [[ ! "$image" =~ ^ghcr\.io/bryanconradhart/strix-halo-server(-[a-z0-9-]+)?(:[A-Za-z0-9][A-Za-z0-9._-]*|@sha256:[a-f0-9]{64})?$ ]]; then
  echo "Image reference is not valid: $image. Check the available image options in the README." >&2
  exit 2
fi

if [[ -n "$key_file" && ! -r "$key_file" ]]; then
  echo "Cannot read SSH public key: $key_file" >&2
  exit 2
fi

for command in curl grep openssl podman; do
  if ! command -v "$command" >/dev/null 2>&1; then
    echo "Required command not found: $command" >&2
    exit 2
  fi
done

if [[ -e "$output" || -L "$output" ]]; then
  read -r -p "$output already exists. Overwrite it? [y/N] " overwrite
  case "$overwrite" in
    y|Y|yes|YES|Yes) ;;
    *)
      echo "Keeping existing $output."
      exit 0
      ;;
  esac
fi

ssh_public_key=
if [[ -n "$key_file" ]]; then
  ssh_public_key=$(<"$key_file")
  if [[ ! "$ssh_public_key" =~ ^(ssh-|ecdsa-|sk-) ]]; then
    echo "The file does not look like an SSH public key: $key_file" >&2
    exit 2
  fi
fi

read -r -s -p "Password for the uCore account 'core': " password
printf '\n'
if [[ -z "$password" ]]; then
  echo "Password must not be empty." >&2
  exit 2
fi
password_hash=$(printf '%s' "$password" | openssl passwd -6 -stdin)
unset password

umask 077
template_file=$(mktemp)
butane_file=$(mktemp)
ignition_file=$(mktemp "./${output}.tmp.XXXXXX")
trap 'rm -f -- "$template_file" "$butane_file" "$ignition_file"' EXIT

curl --fail --silent --show-error --location \
  https://raw.githubusercontent.com/ublue-os/ucore/main/examples/ucore-autorebase.butane \
  --output "$template_file"

skip_ssh_key_entry=false
while IFS= read -r line || [[ -n "$line" ]]; do
  if [[ -z "$ssh_public_key" ]]; then
    if [[ "$line" == *"ssh_authorized_keys:"* ]]; then
      skip_ssh_key_entry=true
      continue
    fi
    if [[ "$skip_ssh_key_entry" == true ]]; then
      if [[ "$line" == *"YOUR_SSH_PUB_KEY_HERE"* ]]; then
        skip_ssh_key_entry=false
        continue
      fi
      echo "Unexpected uCore SSH key template format." >&2
      exit 1
    fi
  else
    line="${line%%YOUR_SSH_PUB_KEY_HERE*}${ssh_public_key}${line#*YOUR_SSH_PUB_KEY_HERE}"
  fi

  line=${line//ghcr.io\/ublue-os\/ucore:stable/$image}
  line=${line//YOUR_GOOD_PASSWORD_HASH_HERE/$password_hash}
  printf '%s\n' "$line"
done < "$template_file" > "$butane_file"

if [[ "$skip_ssh_key_entry" == true ]]; then
  echo "The uCore SSH key template entry was incomplete." >&2
  exit 1
fi

if grep -Fq 'YOUR_SSH_PUB_KEY_HERE' "$butane_file" ||
  grep -Fq 'YOUR_GOOD_PASSWORD_HASH_HERE' "$butane_file" ||
  grep -Fq 'ghcr.io/ublue-os/ucore:stable' "$butane_file"; then
  echo "The uCore template was not fully customized." >&2
  exit 1
fi

podman run --rm --interactive quay.io/coreos/butane:release \
  --pretty --strict < "$butane_file" > "$ignition_file"
chmod 0600 "$ignition_file"
mv -- "$ignition_file" "$output"

echo "Created $output for $image"
echo "It contains your password hash${ssh_public_key:+ and SSH public key}; keep it private."
