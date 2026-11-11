#!/usr/bin/env bash
set -euo pipefail

for grp in wheel video; do
  if ! grep -q "^${grp}:" /etc/group && grep -q "^${grp}:" /usr/lib/group; then
    grep "^${grp}:" /usr/lib/group >> /etc/group
  fi
done

if ! id -u core >/dev/null 2>&1; then
  useradd -M -G wheel,video -s /bin/bash core
else
  usermod -aG wheel,video -s /bin/bash core
fi

echo "core:core" | chpasswd
chage -d 0 core
