#!/usr/bin/env bash
set -euo pipefail

read_validated_input() {
  local prompt=$1
  local pattern=$2
  local error_message=$3
  local value

  for attempt in 1 2 3; do
    if IFS= read -r -s -p "$prompt: " value; then
      printf '\n' >&2
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

if ! api_key=$(read_validated_input \
  "Choose a Lemonade API key (at least 32 letters, numbers, underscores, or hyphens)" \
  '^[[:alnum:]_-]{32,}$' \
  "The API key must be at least 32 letters, numbers, underscores, or hyphens"); then
  exit 1
fi

install -d -o root -g root -m 0711 /etc/lemonade
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
