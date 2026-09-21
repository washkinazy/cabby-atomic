# Universal Blue audit

This document inventories what `ghcr.io/ublue-os/kinoite-main` adds to Fedora
Kinoite. It is a decision aid for moving Cabby Atomic to an official Fedora
base; it is not a list of features that must be copied.

Audit snapshots:

- `ublue-os/main` commit `ef039c5ea3cda28d577acebd6277f1bd7d4ea88f`
- `ublue-os/packages` commit `689e188d67430e9f9ad337ecce7b3fc49363f607`
- Fedora 44 Kinoite source recorded by uBlue:
  `quay.io/fedora-ostree-desktops/kinoite@sha256:766a7184056914e29d6016f4c325d611ebcaf439a6576ec86cf7de56d95b4ffb`

The uBlue repositories are Apache-2.0, but copied rules and third-party assets
must retain their own provenance and applicable notices.

## Build and supply chain

uBlue:

- Pins the Fedora source image by digest and verifies its Fedora signature.
- Pins and verifies its own akmods and Nvidia build images.
- Replaces Fedora's kernel RPMs with signed kernel RPMs from the uBlue akmods
  image, then version-locks the kernel for the remainder of the build.
- Builds a reproducible, non-host-only, zstd-compressed initramfs with the
  `ostree` module explicitly included.
- Runs package-presence checks, `ostree container commit`, and
  `bootc container lint`.
- Publishes signed OCI images with date-based version tags.

Questions for Cabby:

- Use Fedora's kernel unchanged, or own a kernel/akmods pipeline?
- Pin Fedora by digest on every scheduled update PR/build, rather than consume
  a moving tag directly?
- Verify the Fedora source signature before every build?
- Rebuild initramfs reproducibly, or preserve Fedora's image-owned initramfs?

Preliminary direction: keep Fedora's kernel for the base image; copy uBlue's
source pinning, verification, validation, and release metadata patterns. Do not
own an akmods pipeline until the Nvidia variant requires it.

## Multimedia and graphics

uBlue enables Negativo17's Fedora Multimedia repository and gives it higher
priority than Fedora. It installs the complete FFmpeg stack and codecs,
HEIF support, camera/PipeWire extras, VA-API utilities, and Intel VA-API
support. It replaces and version-locks Mesa, libva, Intel media, and libheif
packages from that repository.

This delivers working codecs and less restricted media acceleration, but it is
one of the largest departures from Fedora and introduces another trust and
compatibility boundary. The Mesa version lock also couples image updates to
repository availability.

Decision: **evaluate**. Split the decision into codecs, hardware video decode,
HEIF, camera support, and replacing the Mesa stack; they need not move as one
unit.

## Updates and Flatpak policy

uBlue:

- Stages rpm-ostree updates automatically.
- Enables daily system and per-user Flatpak update timers.
- Avoids updates on metered connections.
- Removes the Fedora Flatpak remote package, installs Flathub, and leaves the
  Fedora and Fedora Testing remotes present but disabled.
- Runs Flatpak unused-package cleanup and repair as part of updates.

Decision: **evaluate**. Cabby's image publication cadence and client update
policy are separate controls. Automatic staging is attractive, while automatic
per-user Flatpak repair may be too invasive for the base image.

## Security and recovery

uBlue:

- Installs a deny-by-default container signature policy with trusted uBlue and
  Toolbx keys while permitting non-registry transports.
- Installs Cosign and verifies build inputs.
- Includes TPM2, FIDO2, PKCS#11, and smart-card dracut modules plus helper
  scripts for TPM-backed LUKS unlock.
- Installs Fedora CoreOS's emergency/rescue sulogin generator.
- Carries a temporary SELinux policy workaround for Linux 7 composefs execmem.

Cabby already owns its image signing policy. The Fedora source-verification and
recovery-generator pieces are strong candidates. LUKS hardware enrollment must
be opt-in and reviewed independently, particularly for AMD TPM threat models.
Temporary SELinux workarounds should only be imported when the matching kernel
issue is present, with an expiry condition.

## Hardware enablement

The main image installs firmware and tools and supplies udev rules for:

- ThinkPad battery charge thresholds.
- Realtek USB Ethernet adapters, including many Lenovo docks.
- Framework 16 expansion modules.
- U2F keys, YubiKeys, Google Titan keys, and smart cards.
- Nintendo Switch/APX, Steam HORIPAD, OpenRGB, Oversteer, Solaar, Wooting,
  ZSA keyboards, Viia, Neutron DAC, and Apple SuperDrive devices.
- iPhone/iPad connectivity through usbmuxd and libimobiledevice tools.

Several legacy rules assign devices to `plugdev`, a group Fedora does not
create. Those rules produced the noisy boot warnings seen during Cabby testing.

Decision: **evaluate rule by rule**. The ThinkPad threshold and Lenovo/Realtek
dock rules are immediately relevant. Prefer `TAG+="uaccess"` over importing a
Debian-style `plugdev` convention. Device-specific rules should identify their
upstream source and tested hardware.

## Desktop and internationalization

For Kinoite, uBlue:

- Installs a broad Fcitx 5 language/input-method set.
- Adds Kate, `ksshaskpass`, and icon utilities.
- Removes the Plasma Discover rpm-ostree backend.
- Version-locks all Qt 6 packages to avoid partial SDDM/KWin upgrades.
- Removes `fedora-third-party` management.

Decision: **evaluate**. Cabby may eventually stop using Plasma as its primary
experience, so KDE-specific policy should not become an accidental permanent
dependency. Input methods should be retained where needed rather than treated
as generic WM infrastructure.

## Command-line and workstation conveniences

The main image adds Distrobox and `flatpak-spawn`; shell and diagnostic tools
including `fzf`, `htop`, `lshw`, `net-tools`, `nvme-cli`, `nvtop`, `powerstat`,
`smartmontools`, `tcpdump`, `tmux`, `traceroute`, `vim`, `wireguard-tools`, and
`wl-clipboard`; broader Noto fonts; and assorted filesystem/archive tools.

It also installs `ujust`, its recipe library, Distrobox defaults, shell
completions, and login tips. Cabby uses Taskfile deliberately, so the recipes
should be reviewed for useful operations and reimplemented as Taskfile tasks or
plain scripts rather than importing `ujust` as a framework.

Decision: **evaluate by function**. Separate rescue/diagnostic tools that must
exist on the host from development tools that belong in Toolbx/Distrobox.

## System policy and cleanup

uBlue additionally:

- Keeps coredumps for five days instead of Fedora's longer default.
- Adds Linuxbrew to sudo's secure path even when Linuxbrew is absent.
- Creates `/var/roothome`.
- Installs Fedora archive repositories.
- Overrides COPR distribution detection so custom branding still resolves
  Fedora chroots.
- Provides optional libvirt sysusers/tmpfiles and SELinux relabel workarounds.
- Provides setup-hook services used by downstream uBlue images.

Decision: **mostly evaluate or omit**. The COPR distribution override is useful
after Cabby changes `ID`/branding. Linuxbrew path changes and generic setup-hook
frameworks should only be included if Cabby intentionally adopts them.

## Nvidia path

uBlue's Nvidia variant is not merely an extra package list. It consumes a
kernel-matched, prebuilt Nvidia akmods image, installs the driver artifacts and
supporting configuration, and ties them to the same pinned kernel used by the
base build.

Decision: **defer until the Fedora-based AMD image is stable**, then design
`main-nvidia` as a separately validated supply chain. Avoid making the AMD/base
image depend on Nvidia build infrastructure.

## Initial decision queue

| Area | Candidate | State |
| --- | --- | --- |
| Supply chain | Fedora digest pinning and signature verification | Discuss first |
| Boot | Reproducible OSTree-aware initramfs generation | Discuss first |
| Recovery | CoreOS sulogin generator | Discuss first |
| Updates | Automatic staged OS updates | Evaluate |
| Flatpak | Flathub defaults and update timers | Evaluate |
| Media | Codecs and hardware acceleration | Evaluate by component |
| Graphics | Negativo17 Mesa replacement/version lock | High-risk evaluation |
| ThinkPad | Battery-threshold rules | Strong candidate |
| Docking | Lenovo/Realtek USB Ethernet rules | Strong candidate |
| Security keys | U2F/YubiKey packages and rules | Evaluate |
| Encryption | TPM2/FIDO2 LUKS support | Opt-in evaluation |
| Host tools | Recovery and diagnostic CLI tools | Evaluate by package |
| Containers | Distrobox and flatpak-spawn integration | Evaluate |
| Operations | ujust recipes | Translate useful recipes to Taskfile |
| KDE | Qt locks, input methods, Discover policy | Evaluate separately |
| Nvidia | Kernel-matched akmods pipeline | Deferred image variant |
| Broad udev rules | Rules using nonexistent `plugdev` | Do not copy as-is |
| Branding | uBlue branding and update keys | Omit |

## Audit follow-up

Before changing the base image, capture machine-readable inventories from the
same Fedora digest and its corresponding uBlue image:

- Installed NEVRA package sets and package origins.
- Enabled and preset system/user units.
- `/usr/lib/{systemd,udev,tmpfiles.d,sysusers.d,dracut}` deltas.
- Container policy, repositories, version locks, and enabled RPM repositories.
- Initramfs module and file inventories.
- OCI labels, kernel version, and bootc lint output.

Store these as generated audit artifacts, not hand-maintained product
configuration. The decision table above should remain the human-owned record.
