#!/usr/bin/env bash

set -euo pipefail

image="${IMAGE:-localhost/cabby-atomic}"
tag="${TAG:-testing}"
base_image="${BASE_IMAGE:-ghcr.io/ublue-os/kinoite-main:latest}"

podman build \
  --pull=newer \
  --build-arg "BASE_IMAGE=${base_image}" \
  --tag "${image}:${tag}" \
  --file Containerfile \
  .

podman image inspect "${image}:${tag}" \
  --format 'Built {{.RepoTags}} ({{.Id}})'
