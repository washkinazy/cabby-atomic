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

## Desktop baseline

The image includes Niri, Hyprland, UWSM, Noctalia, the compositor-specific XDG
desktop portals, and the small set of system services Noctalia drives. Package
selection lives in `packages/desktop.list`. Window-manager and shell
configuration remains in the separate dotfiles repository.

Run the same smoke tests used by CI against a local build:

```bash
task validate
```

## Signature enforcement

Cabby Atomic embeds `cosign.pub` and configures the containers/image policy to
require images pulled from `ghcr.io/washkinazy/cabby-atomic` to carry a valid
Sigstore signature from that key. CI tests this installed policy against the
immutable image digest before advancing a channel tag.

Signature enforcement is established in two steps because Aurora or an older
Cabby deployment does not yet contain the Cabby public key. After the `testing`
workflow succeeds, first deploy and boot the image that contains the policy:

```bash
sudo bootc switch ghcr.io/washkinazy/cabby-atomic:testing
sudo systemctl reboot
```

Then opt the tracked deployment into policy enforcement and reboot once more:

```bash
sudo bootc switch --enforce-container-sigpolicy \
  ghcr.io/washkinazy/cabby-atomic:testing
sudo systemctl reboot
```

The enforcement choice is retained with the image origin, so ordinary future
`bootc upgrade` operations use the installed policy. The policy requires Cabby
images to use the Cabby key while continuing to allow normal Podman pulls from
other repositories.

Inspect or update the deployment:

```bash
bootc status
sudo bootc upgrade --check
sudo bootc upgrade
```

To move a proven laptop from `testing` to the stable channel:

```bash
sudo bootc switch ghcr.io/washkinazy/cabby-atomic:main
sudo systemctl reboot
```

To roll back, select the previous deployment in the boot menu or run:

```bash
sudo bootc rollback
sudo systemctl reboot
```

Before removing the previous Aurora deployment, test one rollback and return to
Cabby Atomic. A failed or unsigned Cabby image should be rejected during
`bootc switch` or `bootc upgrade` before it becomes a deployment.
