ARG BASE_IMAGE="ghcr.io/ublue-os/kinoite-main:latest"

FROM scratch AS build-context
COPY scripts/customize-image.sh /
COPY system_files /system_files

FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="Cabby Atomic"
LABEL org.opencontainers.image.description="A window-manager-focused Fedora Atomic desktop"
LABEL org.opencontainers.image.source="https://github.com/washkinazy/cabby-atomic"

RUN --mount=type=bind,from=build-context,source=/,target=/ctx \
    /ctx/customize-image.sh

RUN bootc container lint
