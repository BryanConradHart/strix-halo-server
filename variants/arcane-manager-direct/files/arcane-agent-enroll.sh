#!/usr/bin/env bash
set -euo pipefail

read_input() {
  local prompt=$1
  local value

  if ! value=$(systemd-ask-password --timeout=180 "$prompt"); then
    echo "Arcane enrollment was skipped or timed out. It will be offered again on the next boot." >&2
    return 1
  fi

  printf '%s' "$value"
}

if ! manager_api_url=$(read_input "Arcane Manager API URL (for example https://arcane.example.com)"); then
  exit 0
fi

if ! agent_token=$(read_input "Arcane Agent token"); then
  exit 0
fi

url_pattern='^https?://[^[:space:]#\\"]+$'
if [[ ! "$manager_api_url" =~ $url_pattern ]]; then
  echo "The Manager URL must start with http:// or https:// and contain no spaces, quotes, backslashes, or fragments."
  exit 1
fi

if [[ ! "$agent_token" =~ ^arc_[[:alnum:]_-]+$ ]]; then
  echo "The Arcane token format is invalid."
  exit 1
fi

install -d -o root -g root -m 0700 /etc/arcane
umask 077
config_tmp=$(mktemp /etc/arcane/agent.env.XXXXXX)
trap 'rm -f "$config_tmp"' EXIT
printf 'AGENT_TOKEN=%s\nMANAGER_API_URL=%s\n' "$agent_token" "$manager_api_url" > "$config_tmp"
chown root:root "$config_tmp"
chmod 0600 "$config_tmp"

systemctl start podman.socket
systemctl daemon-reload
mv "$config_tmp" /etc/arcane/agent.env
trap - EXIT

systemctl start arcane-agent.service
echo "Arcane Agent enrollment completed."
