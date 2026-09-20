# Fedora Atomic

Personal Fedora Atomic desktop images built with bootc. The initial image is
based on Universal Blue Kinoite so Plasma remains available as a fallback while
the Niri, Hyprland, and Noctalia desktop stack is developed.

## Local build

Requirements:

- Podman
- [Task](https://taskfile.dev/)

Build the default local image:

```bash
task build
```

The result is tagged `localhost/fedora-atomic:testing`.

Build arguments can be overridden without editing the Taskfile:

```bash
task build IMAGE=localhost/fedora-atomic TAG=dev \
  BASE_IMAGE=ghcr.io/ublue-os/kinoite-main:latest
```

Fedora's `go-task` package currently installs the executable as `go-task`. If
`task` is not otherwise installed or aliased, use `go-task build`.
