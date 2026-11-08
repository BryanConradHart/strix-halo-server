#!/usr/bin/env bash
set -euo pipefail

read_validated_input() {
  local prompt=$1
  local pattern=$2
  local error_message=$3
  local value

  for attempt in 1 2 3; do
    if IFS= read -r -p "$prompt: " value; then
      if [[ "$value" =~ $pattern ]]; then
        printf '%s' "$value"
        return 0
      fi
      echo "$error_message (attempt $attempt of 3)." >&2
    else
      printf '\n' >&2
      echo "No response received (attempt $attempt of 3)." >&2
    fi
  done

  echo "Setup stopped after 3 attempts. Rerun this command to try again." >&2
  return 1
}

url_pattern='^https?://[^[:space:]#\\"]+$'
if ! app_url=$(read_validated_input \
  "Arcane Manager URL (for example https://arcane.example.com)" \
  "$url_pattern" \
  "The Manager URL must start with http:// or https:// and contain no spaces, quotes, backslashes, or fragments"); then
  exit 1
fi

install -d -o root -g root -m 0700 /etc/arcane
install -d -o 1000 -g 1000 -m 0750 /var/home/core/arcane-projects
encryption_key=$(openssl rand -hex 32)
if [[ ! "$encryption_key" =~ ^[[:xdigit:]]{64}$ ]]; then
  echo "Failed to generate a valid Arcane encryption key."
  exit 1
fi

umask 077
config_tmp=$(mktemp /etc/arcane/manager.env.XXXXXX)
trap 'rm -f "$config_tmp"' EXIT
printf 'APP_URL=%s\nENCRYPTION_KEY=%s\n' "$app_url" "$encryption_key" > "$config_tmp"
chown root:root "$config_tmp"
chmod 0600 "$config_tmp"

systemctl start podman.socket
systemctl daemon-reload
mv "$config_tmp" /etc/arcane/manager.env
trap - EXIT

systemctl start arcane-manager.service
echo "Arcane Manager setup completed. Sign in with the initial credentials and change the password."
