#!/bin/bash
set -e

# Make sure our first-boot runtime engine script is marked executable
chmod +x /usr/local/bin/ucore-first-boot.sh

# Enable the core tuning services globally so they launch on real hardware boot
systemctl enable tuned.service ucore-first-boot.service
