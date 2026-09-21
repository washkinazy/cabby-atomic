ARG BASE_IMAGE="ghcr.io/ublue-os/kinoite-main:44"

FROM scratch AS build-context
COPY scripts/customize-image.sh /
COPY scripts/install-packages.sh /
COPY packages /packages
COPY cosign.pub /
COPY system_files /system_files

FROM ${BASE_IMAGE}

ARG IMAGE_VARIANT="standard"

LABEL org.opencontainers.image.title="Cabby Atomic"
LABEL org.opencontainers.image.description="A window-manager-focused Fedora Atomic desktop"
LABEL org.opencontainers.image.source="https://github.com/washkinazy/cabby-atomic"
LABEL io.github.washkinazy.cabby-atomic.variant="${IMAGE_VARIANT}"

RUN --mount=type=bind,from=build-context,source=/,target=/ctx \
    /ctx/install-packages.sh && \
    CABBY_VARIANT="${IMAGE_VARIANT}" /ctx/customize-image.sh

RUN /usr/libexec/cabby-atomic/validate-image

RUN bootc container lint
