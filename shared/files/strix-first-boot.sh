#!/usr/bin/env bash
set -euo pipefail

/usr/sbin/tuned-adm profile accelerator-performance
/usr/sbin/setsebool -P container_use_devices 1
mkdir -p /var/lib/strix
touch /var/lib/strix/tuned-profile-configured
