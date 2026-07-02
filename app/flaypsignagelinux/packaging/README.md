# Packaging

This directory contains first-pass Linux deployment assets for Flayp Signage Linux.

## Files

- `systemd/flaypsignagelinux.service` - kiosk-style service that starts the player under X.
- `install.sh` - builds the release binary and installs the binary, desktop file, icon, and service.

## Install

From `app/flaypsignagelinux`:

```sh
sudo sh packaging/install.sh
```

The service assumes:

- binary: `/usr/local/bin/flaypsignagelinux`
- data directory: `/var/lib/flaypsignagelinux`
- runtime user: `flaypsignage`

Override install paths with environment variables such as `PREFIX`, `SYSTEMD_DIR`, `DATA_DIR`, and `PLAYER_USER`.

## Ubuntu Desktop Autostart Install

For a normal Ubuntu Desktop session, use the desktop installer instead of the kiosk systemd service:

```sh
sudo CMS_KEY='your-cms-secret' sh packaging/install-ubuntu-desktop.sh
```

Useful overrides:

```sh
sudo TARGET_USER=vulcano CMS_HOST=https://cms.flayp.example/ CMS_KEY='your-cms-secret' sh packaging/install-ubuntu-desktop.sh
```

The desktop installer creates a per-user autostart entry at `~/.config/autostart/flaypsignagelinux.desktop` and uses `~/.local/share/flaypsignagelinux` as the player data directory.
