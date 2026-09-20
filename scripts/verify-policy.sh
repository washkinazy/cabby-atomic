#!/usr/bin/env bash

set -euo pipefail

remote_image="${REMOTE_IMAGE:?REMOTE_IMAGE is required}"
digest="${DIGEST:?DIGEST is required}"
policy_source=system_files/etc/containers/policy.json
registries_dir=system_files/etc/containers/registries.d
workdir="$(mktemp -d)"
verify_ref="localhost/cabby-atomic-policy-check:${digest#sha256:}"

cleanup() {
  podman image rm --force "${verify_ref}" >/dev/null 2>&1 || true
  rm -rf "${workdir}"
}
trap cleanup EXIT

# The installed policy uses the deployed /etc path. Point a temporary copy at
# the repository key so CI exercises the exact same rule before channel tags
# are advanced.
sed "s#/etc/pki/containers/cabby-atomic.pub#${PWD}/cosign.pub#" \
  "${policy_source}" > "${workdir}/policy.json"

skopeo copy \
  --policy "${workdir}/policy.json" \
  --registries.d "${registries_dir}" \
  "docker://${remote_image}@${digest}" \
  "containers-storage:${verify_ref}"

printf 'Policy accepted %s@%s\n' "${remote_image}" "${digest}"
