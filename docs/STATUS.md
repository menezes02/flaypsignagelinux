# Project Status

Date: 2026-07-02

## Complete

- Separate Flayp project folder created at `felipeops/flaypsignagelinux`.
- Source code lives under `app/flaypsignagelinux`.
- Rust package and release binary are named `flaypsignagelinux`.
- Visible product identity uses `Flayp Signage` / `Flayp Signage Linux`.
- Desktop launcher, icon, splash, runtime bridge namespace, CMake library, and packaging assets use Flayp naming.
- Ubuntu Desktop installer supports autostart and offline startup with `--allow-offline`.
- Flayp icon is sourced from `design/flaypsignage.png`.
- GitHub Actions CI added for script validation, desktop metadata validation, tests, and release build.

## Verified Locally

```sh
cargo test --locked
cargo build --release --locked
sh -n packaging/install.sh packaging/install-ubuntu-desktop.sh scripts/check-prereqs.sh
desktop-file-validate flaypsignagelinux.desktop
```

Results:

- Rust tests: 17 passed.
- Release build: passed.
- Desktop file validation: passed.
- Installer shell syntax: passed.
- Branding scan: no copied legacy product references outside ignored build artifacts.

## Next Deployment Step

Install on a target Ubuntu Desktop machine with the real CMS host and registration secret:

```sh
cd app/flaypsignagelinux
sudo TARGET_USER=<desktop-user> \
  CMS_HOST=https://cms.flayp.example/ \
  CMS_KEY='<cms-secret>' \
  sh packaging/install-ubuntu-desktop.sh
```
