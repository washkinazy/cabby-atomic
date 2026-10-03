#!/usr/bin/env bash

set -euo pipefail

image="${IMAGE:-localhost/cabby-atomic}"
tag="${TAG:-testing}"

podman run --rm "${image}:${tag}" \
  /usr/libexec/cabby-atomic/validate-image
