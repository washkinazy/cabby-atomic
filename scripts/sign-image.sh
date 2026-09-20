#!/usr/bin/env bash

set -euo pipefail

remote_image="${REMOTE_IMAGE:?REMOTE_IMAGE is required}"
digest="${DIGEST:?DIGEST is required}"
image_ref="${remote_image}@${digest}"

# bootc and containers/image currently discover legacy Sigstore attachments.
# Keep these compatibility flags until their policy stack supports Cosign's
# newer bundle and registry-referrer defaults.
cosign sign \
  --yes \
  --new-bundle-format=false \
  --use-signing-config=false \
  --key env://COSIGN_PRIVATE_KEY \
  "${image_ref}"

cosign verify \
  --key cosign.pub \
  --new-bundle-format=false \
  "${image_ref}"
