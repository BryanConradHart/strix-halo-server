#!/bin/bash
until systemctl is-active --quiet tuned.service; do sleep 1; done
/usr/sbin/tuned-adm profile accelerator-performance
systemctl disable ucore-first-boot.service
