#!/usr/bin/env bash
set -euo pipefail

read_validated_input() {
  local prompt=$1
  local pattern=$2
  local error_message=$3
  local secret=$4
  local value

  for attempt in 1 2 3; do
    if [[ "$secret" == true ]]; then
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
    elif IFS= read -r -p "$prompt: " value; then
      if [[ "$value" =~ $pattern ]]; then
        printf '%s' "$value"
        return 0
      fi
      echo "$error_message (attempt $attempt of 3)." >&2
    else
      echo "No response received (attempt $attempt of 3)." >&2
    fi
  done

  echo "Enrollment stopped after 3 attempts. Rerun this command to try again." >&2
  return 1
}

url_pattern='^https?://[^[:space:]#\\"]+$'
if ! manager_api_url=$(read_validated_input \
  "Arcane Manager API URL (for example https://arcane.example.com)" \
  "$url_pattern" \
  "The Manager URL must start with http:// or https:// and contain no spaces, quotes, backslashes, or fragments" \
  false); then
  exit 1
fi

if ! agent_token=$(read_validated_input \
  "Arcane Direct Agent token" \
  '^arc_[[:alnum:]_-]+$' \
  "The Arcane token format is invalid" \
  true); then
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
echo "Arcane Direct Agent enrollment completed."
