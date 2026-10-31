#!/usr/bin/env bash
set -euo pipefail

if ! api_key=$(systemd-ask-password --timeout=180 "Choose a Lemonade API key (at least 32 letters, numbers, underscores, or hyphens)"); then
  echo "Lemonade setup was skipped or timed out. It will be offered again at the next boot." >&2
  exit 0
fi

if [[ ! "$api_key" =~ ^[[:alnum:]_-]{32,}$ ]]; then
  echo "The API key must be at least 32 letters, numbers, underscores, or hyphens."
  exit 1
fi

install -d -o root -g root -m 0700 /etc/lemonade
umask 077
config_tmp=$(mktemp /etc/lemonade/server.env.XXXXXX)
trap 'rm -f "$config_tmp"' EXIT
printf 'LEMONADE_API_KEY=%s\n' "$api_key" > "$config_tmp"
chown root:root "$config_tmp"
chmod 0600 "$config_tmp"

systemctl start podman.socket
systemctl daemon-reload
mv "$config_tmp" /etc/lemonade/server.env
trap - EXIT

systemctl start lemonade-server.service
echo "Lemonade Server setup completed. Keep the API key available for client configuration."
