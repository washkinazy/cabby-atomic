# Package migration policy

Cabby builds the workstation package set on top of the current Cabby/uBlue
image. The base image is authoritative: when it already provides a package or a
capability, Cabby does not reproduce the old installation pattern.

## Inherited from the base

The following areas are deliberately absent from Cabby's package lists because
the current image already owns them:

- firmware and CPU microcode;
- core system packages and power management;
- the multimedia repository, codecs, and FFmpeg selection;
- the base desktop portals and Qt Wayland integration;
- Podman, Distrobox, and the basic Vulkan stack;
- KDE and the packages already present in the Kinoite-derived image.

This also means there is no Cabby equivalent of the old `@multimedia` install or
the `ffmpeg-free` to `ffmpeg` swap.

## Cabby package layers

- `desktop.list` contains the Cabby Wayland session itself.
- `workstation.list` contains requested packages missing from the current image
  that resolve from inherited repositories or Cabby's Hyprland COPR.
- `terra.list` contains only packages with no inherited provider.

Terra is explicitly disabled during the workstation transaction. It is enabled
only for the narrow Terra package transaction and is not used as a replacement
for uBlue's Mesa or multimedia choices.

## Replaced or external items

- The unavailable `p7zip` and `p7zip-plugins` packages are satisfied by `7zip`,
  which is already in the base image.
- The old `vim` request is satisfied by the base image's `vim-enhanced` package.
- Fedora's `go-task` package installs the binary as `go-task`; Cabby supplies a
  `task` compatibility entry point so repository commands remain portable.
- Flatpak applications remain part of userspace provisioning and are not baked
  into the bootc image.
- Users, dotfiles, hostnames, storage mounts, service enrollment, and other
  machine-specific state remain outside the image.
- NVIDIA driver packaging belongs to the future NVIDIA image variant, not the
  shared workstation package layer.
