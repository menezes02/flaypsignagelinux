#!/usr/bin/env sh
set -eu

APP_NAME=flaypsignagelinux
PREFIX=${PREFIX:-/usr/local}
SYSTEMD_DIR=${SYSTEMD_DIR:-/etc/systemd/system}
DATA_DIR=${DATA_DIR:-/var/lib/flaypsignagelinux}
PLAYER_USER=${PLAYER_USER:-flaypsignage}

cargo build --release

install -Dm755 "target/release/$APP_NAME" "$PREFIX/bin/$APP_NAME"
install -Dm644 "$APP_NAME.desktop" "$PREFIX/share/applications/$APP_NAME.desktop"
install -Dm644 "assets/$APP_NAME.png" "$PREFIX/share/pixmaps/$APP_NAME.png"
install -Dm644 "packaging/systemd/$APP_NAME.service" "$SYSTEMD_DIR/$APP_NAME.service"

if ! id "$PLAYER_USER" >/dev/null 2>&1; then
  useradd --system --home-dir "$DATA_DIR" --create-home --shell /usr/sbin/nologin "$PLAYER_USER"
fi

mkdir -p "$DATA_DIR"
chown "$PLAYER_USER:$PLAYER_USER" "$DATA_DIR"

if command -v systemctl >/dev/null 2>&1; then
  systemctl daemon-reload
fi

printf 'Installed %s. Configure with:
  %s --host https://your-cms.example/ --key YOUR_KEY %s
' "$APP_NAME" "$APP_NAME" "$DATA_DIR"
