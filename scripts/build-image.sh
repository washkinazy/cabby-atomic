#!/usr/bin/env bash

set -euo pipefail

image="${IMAGE:-localhost/cabby-atomic}"
tag="${TAG:-testing}"
base_image="${BASE_IMAGE:-ghcr.io/ublue-os/kinoite-main:44}"
image_variant="${IMAGE_VARIANT:-standard}"

case "${image_variant}" in
  standard | nvidia) ;;
  *)
    printf 'Unsupported IMAGE_VARIANT: %s\n' "${image_variant}" >&2
    exit 1
    ;;
esac

podman build \
  --pull=newer \
  --build-arg "BASE_IMAGE=${base_image}" \
  --build-arg "IMAGE_VARIANT=${image_variant}" \
  --tag "${image}:${tag}" \
  --file Containerfile \
  .

podman image inspect "${image}:${tag}" \
  --format 'Built {{.RepoTags}} ({{.Id}})'
