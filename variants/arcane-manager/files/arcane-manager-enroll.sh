#!/usr/bin/env bash
set -euo pipefail

if ! app_url=$(systemd-ask-password --timeout=180 "Arcane Manager URL (for example https://arcane.example.com)"); then
  echo "Arcane Manager setup was skipped or timed out. It will be offered again at the next boot." >&2
  exit 0
fi

url_pattern='^https?://[^[:space:]#\\"]+$'
if [[ ! "$app_url" =~ $url_pattern ]]; then
  echo "The Manager URL must start with http:// or https:// and contain no spaces, quotes, backslashes, or fragments."
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
