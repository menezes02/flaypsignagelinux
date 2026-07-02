# Flayp Linux Player for Xibo

![CI](https://github.com/menezes02/flaypsignagelinux/actions/workflows/ci.yml/badge.svg)
![License](https://img.shields.io/badge/license-AGPL--3.0--or--later-blue)
![Rust](https://img.shields.io/badge/Rust-1.75%2B-orange)
![Qt](https://img.shields.io/badge/Qt-6%20WebEngine-41CD52)

Flayp Linux Player for Xibo is a white-label Linux digital signage player built with Rust and Qt 6 WebEngine. It registers with a Xibo-compatible CMS, downloads scheduled layouts and media, caches content locally, and keeps playback running full-screen for Ubuntu desktop signage deployments.

This repository is structured as a production-style signage player project: branded app assets, install scripts, offline playback support, CI checks, and documentation for build, deployment, and architecture.

## Highlights

- Full-screen Linux signage playback for Xibo CMS using Qt 6 WebEngine.
- Rust backend for registration, scheduling, media caching, commands, logging, and status collection.
- Offline startup mode that uses cached settings, schedule, layouts, and media when the CMS is unavailable.
- Ubuntu Desktop installer with per-user autostart, app launcher, single-instance lock, and persistent logs.
- HiDPI-aware layout scaling for 1080p/4K displays.
- White-label Flayp branding, app icon, splash screen, desktop metadata, binary name, and runtime bridge namespace.
- CI workflow for script validation, desktop metadata validation, Rust tests, and release build.

## Repository Layout

```text
app/flaypsignagelinux/       Rust + Qt application source
design/                      Flayp brand asset used for the app icon
docs/                        Build, install, architecture, offline, and branding notes
source/                      Reserved for future source snapshots or vendor-cleared drops
.github/workflows/ci.yml     GitHub Actions validation pipeline
```

## Quick Start

Install build dependencies on Ubuntu 24.04 or similar:

```sh
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
  cmake g++ cargo rustc libdbus-1-dev libzmq3-dev \
  qt6-webengine-dev libudev-dev pkg-config desktop-file-utils
```

Build and test:

```sh
cd app/flaypsignagelinux
cargo test --locked
cargo build --release --locked
```

Run first-time registration against a CMS:

```sh
mkdir -p ~/.local/share/flaypsignagelinux
target/release/flaypsignagelinux \
  --host https://xibo.example.com/ \
  --key YOUR_CMS_SECRET \
  ~/.local/share/flaypsignagelinux
```

After registration, start with offline fallback enabled:

```sh
target/release/flaypsignagelinux --allow-offline ~/.local/share/flaypsignagelinux
```

## Ubuntu Desktop Install

The desktop installer builds the release binary, installs the icon, creates a per-user launcher, configures autostart, and uses offline fallback by default.

```sh
cd app/flaypsignagelinux
sudo TARGET_USER=$USER \
  CMS_HOST=https://xibo.example.com/ \
  CMS_KEY='YOUR_CMS_SECRET' \
  sh packaging/install-ubuntu-desktop.sh
```

The installed launcher logs to:

```text
~/.local/state/flaypsignagelinux/player.log
```

## Documentation

- [Architecture](docs/ARCHITECTURE.md)
- [Ubuntu Desktop Install](docs/INSTALL_UBUNTU_DESKTOP.md)
- [Offline Mode](docs/OFFLINE_MODE.md)
- [Build Notes](docs/BUILD.md)
- [Branding Notes](docs/BRANDING.md)
- [Project Status](docs/STATUS.md)

## Recruiter Notes

This project demonstrates practical systems engineering across a desktop Linux product surface: Rust application logic, Qt/C++ integration, local caching, offline behavior, installation automation, desktop session quirks, CI, and production documentation. The emphasis is on making a signage player that can survive real deployments: network outages, reboot/autostart, cached media playback, HiDPI screens, and repeatable installs.

## License

AGPL-3.0-or-later. See [app/flaypsignagelinux/LICENSE](app/flaypsignagelinux/LICENSE).
