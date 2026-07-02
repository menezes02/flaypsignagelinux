# Flayp Signage Linux

Flayp Signage Linux is a Linux digital signage player for Flayp CMS. It is
implemented mostly in Rust and uses Qt GUI components for Linux platforms.

The player is intended for kiosk-style signage deployments where the device
connects to a Flayp CMS, downloads scheduled content, caches media locally, and
runs the display full screen.

## Installation

To build from source, you need:

* The Rust toolchain, version >= 1.75.
* CMake and a C++ compiler.
* Qt 6 with the QtWebEngine component and development headers.
* Development headers for `dbus` (>= 1.6), `zeromq` (>= 4.1), and `pkg-config`.

To build, run:

```sh
cargo build --release
```

The binary is placed in `target/release/flaypsignagelinux`.

To install the binary, desktop file, icon, and systemd service, run:

```sh
sudo sh packaging/install.sh
```

For RHEL derived distributions, install `cmake gcc-c++ cargo dbus-devel
zeromq-devel qt6-qtwebengine-devel`. For Debian derived, install `cmake g++
cargo libdbus-1-dev libzmq3-dev qt6-webengine-dev pkg-config`.

## Usage

Create a new directory where Flayp Signage Linux can store configuration and
media files. Then, at first start, use the following command line to configure
the player:

```sh
flaypsignagelinux --host <https://my.cms/> --key <key> <dir>
```

Further configuration options are `--display-id` (normally auto-generated from
machine characteristics), `--display-name`, and `--proxy`.

Flayp Signage Linux caches the configuration in the directory, so future starts
only need:

```sh
flaypsignagelinux <dir>
```

Log messages are printed to stdout. The GUI window appears once the display is
authorized in the CMS.

## Standalone Setup With X Server

Example systemd service command for a kiosk-style X session:

```ini
ExecStart=/usr/bin/xinit /usr/local/bin/flaypsignagelinux /var/lib/flaypsignagelinux -- :0 vt2 -s 0 -v -dpms
```
