#!/usr/bin/env bash

set -euo pipefail

os_release=/usr/lib/os-release
image_variant="${CABBY_VARIANT:-standard}"

case "${image_variant}" in
  standard | nvidia) ;;
  *)
    printf 'Unsupported Cabby image variant: %s\n' "${image_variant}" >&2
    exit 1
    ;;
esac

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
chmod 0755 /usr/libexec/cabby-atomic/validate-image
printf '%s\n' "${image_variant}" > /usr/libexec/cabby-atomic/variant

if ! cmp -s /ctx/cosign.pub /etc/pki/containers/cabby-atomic.pub; then
  printf 'Embedded signing key does not match cosign.pub\n' >&2
  exit 1
fi

# Plymouth assets must be embedded in the image-owned initramfs. Build it as a
# reproducible, non-host-only image and explicitly include OSTree prepare-root;
# without that module, switch-root sees the raw Btrfs root and enters emergency
# mode instead of mounting the selected deployment.
kernel_version="$(rpm -q --queryformat='%{evr}.%{arch}' kernel-core)"
initramfs="/usr/lib/modules/${kernel_version}/initramfs.img"

export DRACUT_NO_XATTR=1
dracut \
  --no-hostonly \
  --reproducible \
  --add ostree \
  --kver "${kernel_version}" \
  --force "${initramfs}"
chmod 0600 "${initramfs}"
