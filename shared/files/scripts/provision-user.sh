#!/usr/bin/env bash
set -euo pipefail

if ! id -u core >/dev/null 2>&1; then
  useradd -M -G wheel,video -s /bin/bash core
else
  usermod -aG wheel,video -s /bin/bash core
fi

echo "core:core" | chpasswd
chage -d 0 core
