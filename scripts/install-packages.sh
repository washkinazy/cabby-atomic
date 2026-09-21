#!/usr/bin/env bash

set -euo pipefail

read_package_lists() {
  sed -e 's/#.*//' -e '/^[[:space:]]*$/d' "$@"
}

mapfile -t packages < <(read_package_lists \
  /ctx/packages/desktop.list \
  /ctx/packages/workstation.list)

mapfile -t terra_packages < <(read_package_lists \
  /ctx/packages/terra.list)

dnf5 -y copr enable lionheartp/Hyprland

if ((${#terra_packages[@]} > 0)); then
  # Terra's release RPM provides its signing keys and repository definition.
  # Bootstrap it from Terra's official base URL, then use that same URL rather
  # than a mirror for deterministic metadata during image builds.
  # shellcheck disable=SC2016 # DNF expands $releasever, not the shell.
  dnf5 -y --nogpgcheck \
    --repofrompath 'terra-bootstrap,https://repos.fyralabs.com/terra$releasever' \
    install terra-release
  sed -i \
    -e 's|^#baseurl=|baseurl=|' \
    -e 's|^metalink=|#metalink=|' \
    /etc/yum.repos.d/terra.repo
  dnf5 -y makecache --repo terra
fi

# The inherited uBlue repositories and package choices are the baseline. In
# particular, do not reproduce the old multimedia group or ffmpeg swap here.
# Terra is excluded from this transaction so it cannot replace uBlue's Mesa or
# multimedia stack after its narrowly scoped packages are added below.
dnf5 -y \
  --setopt=install_weak_deps=False \
  --disablerepo=terra \
  install "${packages[@]}"

if ((${#terra_packages[@]} > 0)); then
  dnf5 -y \
    --setopt=allow_vendor_change=False \
    --setopt=install_weak_deps=False \
    install "${terra_packages[@]}"
fi

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
