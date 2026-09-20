ARG BASE_IMAGE="ghcr.io/ublue-os/kinoite-main:latest"
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="fedora-atomic"
LABEL org.opencontainers.image.description="Personal Fedora Atomic desktop image"
LABEL org.opencontainers.image.source="https://github.com/washkinazy/fedora-atomic"

# Keep the first milestone deliberately small: prove that the selected desktop
# base can be built locally as a valid bootc image before adding customization.
RUN bootc container lint
