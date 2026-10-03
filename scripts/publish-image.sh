#!/usr/bin/env bash

set -euo pipefail

image="${IMAGE:-localhost/cabby-atomic}"
tag="${TAG:?TAG is required}"
remote_image="${REMOTE_IMAGE:?REMOTE_IMAGE is required}"
remote_tag="${REMOTE_TAG:-${tag}}"
digest_file="${DIGEST_FILE:-/tmp/cabby-atomic-digest}"

podman push \
  --digestfile="${digest_file}" \
  "${image}:${tag}" \
  "${remote_image}:${remote_tag}"

printf 'Published %s@%s\n' "${remote_image}" "$(<"${digest_file}")"
