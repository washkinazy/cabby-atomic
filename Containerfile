ARG BASE_IMAGE="ghcr.io/ublue-os/kinoite-main:latest"

FROM scratch AS build-context
COPY scripts/customize-image.sh /
COPY scripts/install-packages.sh /
COPY packages /packages
COPY cosign.pub /
COPY system_files /system_files

FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="Cabby Atomic"
LABEL org.opencontainers.image.description="A window-manager-focused Fedora Atomic desktop"
LABEL org.opencontainers.image.source="https://github.com/washkinazy/cabby-atomic"

RUN --mount=type=bind,from=build-context,source=/,target=/ctx \
    /ctx/install-packages.sh && \
    /ctx/customize-image.sh

RUN /usr/libexec/cabby-atomic/validate-image

RUN bootc container lint
