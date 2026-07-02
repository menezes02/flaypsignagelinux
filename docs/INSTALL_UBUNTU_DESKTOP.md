# Ubuntu Desktop Install

This is the recommended install path for a normal Ubuntu Desktop session.

## Install

From the app directory:

```sh
cd app/flaypsignagelinux
sudo TARGET_USER=$USER \
  CMS_HOST=https://xibo.example.com/ \
  CMS_KEY='YOUR_CMS_SECRET' \
  sh packaging/install-ubuntu-desktop.sh
```

Useful environment variables:

- `TARGET_USER`: desktop user that should own the launcher and cache.
- `CMS_HOST`: CMS base URL.
- `CMS_KEY`: registration secret.
- `INSTALL_DEPS=0`: skip apt dependency install on prepared machines.
- `REGISTER_NOW=0`: install only, without initial CMS registration.

## Installed Paths

```text
/usr/local/bin/flaypsignagelinux
/usr/local/share/pixmaps/flaypsignagelinux.png
~/.local/bin/flaypsignagelinux-start
~/.local/share/flaypsignagelinux
~/.local/share/applications/flaypsignagelinux.desktop
~/.config/autostart/flaypsignagelinux.desktop
~/.local/state/flaypsignagelinux/player.log
```

## Start Manually

```sh
~/.local/bin/flaypsignagelinux-start
```

The starter runs the player with `--allow-offline`, repairs missing desktop session variables, and prevents duplicate instances.
