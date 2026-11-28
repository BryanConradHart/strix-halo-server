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

# True when a drop-in for this unit already provides $1, ignoring the setup
# env file (setup regenerates that file; only user-authored drop-ins and the
# env files they reference count). Computed fresh on every run via systemd's
# merged unit view, so removing a drop-in makes the value unset again and the
# next setup run collects it. See /usr/libexec/spos-quadlet-env.sh.
. /usr/libexec/spos-quadlet-env.sh
override_provides() {
  spos_quadlet_provides lemonade-server.service "$1" /etc/lemonade/server.env
}

# --check reports completeness for the login-time notice, which runs as an
# unprivileged user and cannot read the 0600 env file. Exit 0 = incomplete.
# It deliberately skips the daemon-reload below so logging in has no side
# effects; drop-ins added since the last reload are picked up on next boot.
if [[ ${1:-} == --check ]]; then
  if spos_setup_incomplete lemonade-server.service /etc/lemonade/server.env \
      LEMONADE_API_KEY; then
    exit 0
  fi
  exit 1
fi

# Reload so drop-ins added since boot are part of the merged unit before it is
# used for the prompts below.
systemctl daemon-reload

api_key=
if override_provides LEMONADE_API_KEY; then
  echo "LEMONADE_API_KEY is set by your drop-in override; not asking for it."
  # Keep the previous value (if any) as a fallback in case the override is
  # removed before the next setup run.
  api_key=$(sed -nE 's/^[[:space:]]*LEMONADE_API_KEY=//p' /etc/lemonade/server.env 2>/dev/null | tail -n1)
elif ! api_key=$(read_validated_input \
  "Choose a Lemonade API key (at least 32 letters, numbers, underscores, or hyphens)" \
  '^[[:alnum:]_-]{32,}$' \
  "The API key must be at least 32 letters, numbers, underscores, or hyphens"); then
  exit 1
fi

install -d -o root -g root -m 0711 /etc/lemonade

umask 077
config_tmp=$(mktemp /etc/lemonade/server.env.XXXXXX)
trap 'rm -f "$config_tmp"' EXIT
: > "$config_tmp"
if [[ -n $api_key ]]; then printf 'LEMONADE_API_KEY=%s\n' "$api_key" >> "$config_tmp"; fi
chown root:root "$config_tmp"
chmod 0600 "$config_tmp"

systemctl start podman.socket
systemctl daemon-reload
mv "$config_tmp" /etc/lemonade/server.env
trap - EXIT

systemctl start lemonade-server.service
echo "Lemonade Server setup completed. Keep the API key available for client configuration."
