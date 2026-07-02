#!/usr/bin/env sh
set -eu
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PATH

APP_NAME=flaypsignagelinux
PRODUCT_NAME="Flayp Signage"
PREFIX=${PREFIX:-/usr/local}
TARGET_USER=${TARGET_USER:-${SUDO_USER:-}}
CMS_HOST=${CMS_HOST:-https://cms.flayp.example/}
CMS_KEY=${CMS_KEY:-}
INSTALL_DEPS=${INSTALL_DEPS:-1}
REGISTER_NOW=${REGISTER_NOW:-1}

if [ "$(id -u)" -ne 0 ]; then
  echo "Run this installer with sudo." >&2
  echo "Example: sudo CMS_KEY='your-cms-secret' sh packaging/install-ubuntu-desktop.sh" >&2
  exit 1
fi

if [ -z "$TARGET_USER" ] || [ "$TARGET_USER" = "root" ]; then
  echo "Set TARGET_USER to the Ubuntu desktop user, for example: TARGET_USER=vulcano" >&2
  exit 1
fi

TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)
if [ -z "$TARGET_HOME" ] || [ ! -d "$TARGET_HOME" ]; then
  echo "Could not find home directory for user $TARGET_USER" >&2
  exit 1
fi

TARGET_UID=$(id -u "$TARGET_USER")
DATA_DIR=${DATA_DIR:-$TARGET_HOME/.local/share/$APP_NAME}
AUTOSTART_DIR="$TARGET_HOME/.config/autostart"
USER_APPLICATIONS_DIR="$TARGET_HOME/.local/share/applications"
LOCAL_BIN_DIR="$TARGET_HOME/.local/bin"
STARTER="$LOCAL_BIN_DIR/$APP_NAME-start"
LOG_DIR="$TARGET_HOME/.local/state/$APP_NAME"

if [ "$INSTALL_DEPS" = "1" ]; then
  apt-get update
  apt-get install -y --no-install-recommends \
    cmake \
    g++ \
    cargo \
    rustc \
    libdbus-1-dev \
    libzmq3-dev \
    qt6-webengine-dev \
    libudev-dev \
    pkg-config
fi

cargo build --release

install -Dm755 "target/release/$APP_NAME" "$PREFIX/bin/$APP_NAME"
install -Dm644 "assets/$APP_NAME.png" "$PREFIX/share/pixmaps/$APP_NAME.png"

mkdir -p "$DATA_DIR" "$AUTOSTART_DIR" "$USER_APPLICATIONS_DIR" "$LOCAL_BIN_DIR" "$LOG_DIR"
chown -R "$TARGET_USER:$TARGET_USER" "$DATA_DIR" "$AUTOSTART_DIR" "$USER_APPLICATIONS_DIR" "$LOCAL_BIN_DIR" "$LOG_DIR"

cat > "$STARTER" <<EOF
#!/usr/bin/env sh
set -eu
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PATH
if [ -z "\${XDG_RUNTIME_DIR:-}" ]; then
  XDG_RUNTIME_DIR="/run/user/\$(id -u)"
  export XDG_RUNTIME_DIR
fi
if [ -z "\${DBUS_SESSION_BUS_ADDRESS:-}" ] && [ -S "\$XDG_RUNTIME_DIR/bus" ]; then
  DBUS_SESSION_BUS_ADDRESS="unix:path=\$XDG_RUNTIME_DIR/bus"
  export DBUS_SESSION_BUS_ADDRESS
fi
if [ -z "\${XAUTHORITY:-}" ] && [ -f "\$HOME/.Xauthority" ]; then
  XAUTHORITY="\$HOME/.Xauthority"
  export XAUTHORITY
fi
APP_NAME=$APP_NAME
STATE_DIR="\$HOME/.local/state/\$APP_NAME"
DATA_DIR="\$HOME/.local/share/\$APP_NAME"
LOG_FILE="\$STATE_DIR/player.log"
LOCK_FILE="\$STATE_DIR/player.lock"
mkdir -p "\$STATE_DIR" "\$DATA_DIR"
{
  echo "---- \$(date -Is) launcher invoked ----"
  echo "DISPLAY=\${DISPLAY:-} WAYLAND_DISPLAY=\${WAYLAND_DISPLAY:-} XDG_SESSION_TYPE=\${XDG_SESSION_TYPE:-}"
} >>"\$LOG_FILE"
exec >>"\$LOG_FILE" 2>&1
exec 9>"\$LOCK_FILE"
if ! flock -n 9; then
  echo "\$(date -Is) \$APP_NAME already running; ignoring duplicate launch" >>"\$LOG_FILE"
  exit 0
fi
set +e
$PREFIX/bin/$APP_NAME --allow-offline "\$DATA_DIR"
code=\$?
set -e
echo "\$(date -Is) player exited with code \$code"
exit "\$code"
EOF
chmod +x "$STARTER"
chown "$TARGET_USER:$TARGET_USER" "$STARTER"

cat > "$AUTOSTART_DIR/$APP_NAME.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=$PRODUCT_NAME
GenericName=Digital Signage Player
Comment=Start $PRODUCT_NAME at login
Exec=/usr/bin/setsid $STARTER
Icon=$APP_NAME
Terminal=false
Categories=Utility;
X-GNOME-Autostart-enabled=true
X-GNOME-Autostart-Delay=10
EOF
chown "$TARGET_USER:$TARGET_USER" "$AUTOSTART_DIR/$APP_NAME.desktop"

cat > "$USER_APPLICATIONS_DIR/$APP_NAME.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=$PRODUCT_NAME
GenericName=Digital Signage Player
Comment=Start $PRODUCT_NAME
Exec=/usr/bin/setsid $STARTER
Icon=$APP_NAME
Terminal=false
Categories=Utility;
Keywords=signage;digital;kiosk;flayp;
StartupNotify=true
EOF
chown "$TARGET_USER:$TARGET_USER" "$USER_APPLICATIONS_DIR/$APP_NAME.desktop"
runuser -u "$TARGET_USER" -- update-desktop-database "$USER_APPLICATIONS_DIR" >/dev/null 2>&1 || true

if [ "$REGISTER_NOW" = "1" ]; then
  if [ -z "$CMS_KEY" ]; then
    echo "CMS_KEY is required for initial CMS registration." >&2
    echo "Re-run with: sudo CMS_KEY='your-cms-secret' sh packaging/install-ubuntu-desktop.sh" >&2
    exit 1
  fi

  set +e
  runuser -u "$TARGET_USER" -- env \
    DISPLAY="${DISPLAY:-}" \
    WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-}" \
    XDG_RUNTIME_DIR="/run/user/$TARGET_UID" \
    DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$TARGET_UID/bus" \
    timeout 45s "$PREFIX/bin/$APP_NAME" --host "$CMS_HOST" --key "$CMS_KEY" "$DATA_DIR"
  code=$?
  set -e

  case "$code" in
    0)
      echo "Initial CMS registration/run completed."
      ;;
    2)
      echo "Initial CMS registration reached CMS. Authorize the display, then log out/in or run: $STARTER"
      ;;
    124)
      echo "Initial run timed out after 45 seconds. If the player opened, this is acceptable for an authorized display."
      ;;
    *)
      echo "Initial CMS registration exited with code $code. Check $LOG_DIR/player.log or run manually:" >&2
      echo "  $PREFIX/bin/$APP_NAME --host '$CMS_HOST' --key '<secret>' '$DATA_DIR'" >&2
      exit "\$code"
      ;;
  esac
fi

cat <<EOF
Installed $PRODUCT_NAME for Ubuntu Desktop.

User: $TARGET_USER
Binary: $PREFIX/bin/$APP_NAME
Data directory: $DATA_DIR
Autostart: $AUTOSTART_DIR/$APP_NAME.desktop
App menu launcher: $USER_APPLICATIONS_DIR/$APP_NAME.desktop
Launcher: $STARTER

To start now from the desktop session:
  $STARTER
EOF
