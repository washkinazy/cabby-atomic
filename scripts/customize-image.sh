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
chmod 0755 /usr/libexec/cabby-atomic/validate-image

if ! cmp -s /ctx/cosign.pub /etc/pki/containers/cabby-atomic.pub; then
  printf 'Embedded signing key does not match cosign.pub\n' >&2
  exit 1
fi

# Keep the base image's initramfs intact. Regenerating it from inside the image
# build omits OSTree prepare-root integration because the build container is not
# itself OSTree-booted, leaving /sysroot mounted as the raw Btrfs root and
# causing initrd-switch-root.service to enter emergency mode.
