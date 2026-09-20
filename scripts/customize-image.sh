#!/usr/bin/env bash

set -euo pipefail

os_release=/usr/lib/os-release

# shellcheck disable=SC1090
source "${os_release}"

if [[ ! "${VERSION_ID:-}" =~ ^[0-9]+$ ]]; then
  printf 'Unexpected Fedora VERSION_ID: %s\n' "${VERSION_ID:-missing}" >&2
  exit 1
fi

sed -i \
  -e 's/^NAME=.*/NAME="Cabby Atomic"/' \
  -e "s/^PRETTY_NAME=.*/PRETTY_NAME=\"Cabby Atomic: ${VERSION_ID}\"/" \
  "${os_release}"

if grep -q '^IMAGE_ID=' "${os_release}"; then
  sed -i 's/^IMAGE_ID=.*/IMAGE_ID=cabby-atomic/' "${os_release}"
else
  printf 'IMAGE_ID=cabby-atomic\n' >> "${os_release}"
fi

cp -a /ctx/system_files/. /

# Plymouth assets are embedded in the bootable initramfs, so changing only the
# root filesystem copy would leave the old Fedora watermark visible at boot.
# Target bootc's image-owned initramfs directly; --regenerate-all writes a new
# file under /boot, which bootc ignores and its container lint rejects.
for module_dir in /usr/lib/modules/*; do
  [[ -d "${module_dir}" ]] || continue
  kernel_version="${module_dir##*/}"
  dracut --force "${module_dir}/initramfs.img" "${kernel_version}"
done
