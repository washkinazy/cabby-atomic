# Cabby Atomic

A window-manager-focused Fedora Atomic desktop built with bootc. The initial
image is based on Universal Blue Kinoite so Plasma remains available as a
fallback while the Niri, Hyprland, and Noctalia desktop stack is developed.

## Local build

Requirements:

- Podman
- [Task](https://taskfile.dev/)

Build the default local image:

```bash
task build
```

The result is tagged `localhost/cabby-atomic:testing`.

The image identifies itself as `Cabby Atomic: <Fedora version>` in the boot menu
and uses a cabby-hat watermark on the Plymouth boot splash.

Build arguments can be overridden without editing the Taskfile:

```bash
task build IMAGE=localhost/cabby-atomic TAG=dev \
  BASE_IMAGE=ghcr.io/ublue-os/kinoite-main:latest
```

Fedora's `go-task` package currently installs the executable as `go-task`. If
`task` is not otherwise installed or aliased, use `go-task build`.

## Published channels

GitHub Actions builds pull requests without publishing them. Merges to the
`testing` and `main` branches publish the corresponding image tag:

```text
ghcr.io/washkinazy/cabby-atomic:testing
ghcr.io/washkinazy/cabby-atomic:main
```

The `main` channel is also rebuilt every Sunday to incorporate upstream image
updates. Published images are signed by digest with Cosign and verified before
the workflow succeeds.
