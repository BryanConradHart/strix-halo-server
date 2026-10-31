#!/usr/bin/env bash
set -euo pipefail

/usr/sbin/tuned-adm profile accelerator-performance
touch /var/lib/strix/tuned-profile-configured
