#!/usr/bin/env bash

set -euo pipefail

mapfile -t packages < <(sed -e 's/#.*//' -e '/^[[:space:]]*$/d' \
  /ctx/packages/desktop.list)

dnf5 -y copr enable lionheartp/Hyprland
dnf5 -y --setopt=install_weak_deps=False install "${packages[@]}"
dnf5 clean all

# Package transactions leave mutable caches and logs that do not belong in a
# bootc image. The enabled COPR definition itself remains under /etc/yum.repos.d
# so future image builds can resolve upgrades from the same source.
rm -rf \
  /run/dnf \
  /var/cache/libdnf5 \
  /var/cache/ldconfig/aux-cache \
  /var/lib/dnf \
  /var/log/dnf5.log
