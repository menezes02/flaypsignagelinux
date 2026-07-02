# Build Notes

## Requirements

- Rust 1.75 or newer
- CMake
- C++ compiler
- Qt 6 WebEngine development headers
- `dbus`, `zeromq`, `libudev`, and `pkg-config` development packages

Ubuntu baseline:

```sh
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
  cmake g++ cargo rustc libdbus-1-dev libzmq3-dev \
  qt6-webengine-dev libudev-dev pkg-config desktop-file-utils
```

## Build

```sh
cd app/flaypsignagelinux
cargo build --release --locked
```

Release binary:

```text
app/flaypsignagelinux/target/release/flaypsignagelinux
```

## Test

```sh
cd app/flaypsignagelinux
cargo test --locked
```

## Validate Packaging Files

```sh
cd app/flaypsignagelinux
sh -n packaging/install.sh packaging/install-ubuntu-desktop.sh scripts/check-prereqs.sh
desktop-file-validate flaypsignagelinux.desktop
```
