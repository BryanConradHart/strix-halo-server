#!/bin/bash
set -e
chmod +x /usr/local/bin/ucore-first-boot.sh
systemctl enable podman.socket podman-restart.service tuned.service ucore-first-boot.service
