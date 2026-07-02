#!/usr/bin/env sh
set -eu

missing=0
check_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'missing command: %s\n' "$1"
    missing=1
  fi
}
check_pkg() {
  if ! pkg-config --exists "$1"; then
    printf 'missing pkg-config package: %s\n' "$1"
    missing=1
  fi
}

check_cmd cargo
check_cmd rustc
check_cmd cmake
check_cmd pkg-config
check_pkg dbus-1
check_pkg libzmq
check_pkg Qt6WebEngineWidgets

if [ "$missing" -ne 0 ]; then
  cat <<'MSG'

Install baseline dependencies on Debian/Ubuntu with:
  sudo apt install cmake g++ cargo libdbus-1-dev libzmq3-dev qt6-webengine-dev pkg-config

Then run:
  cargo build --release
MSG
  exit 1
fi

printf 'All required build prerequisites were found.\n'
