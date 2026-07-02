# Architecture

Flayp Linux Player for Xibo is split into a Rust backend and a Qt 6 WebEngine frontend.

## Runtime Flow

1. Load CMS configuration from the envdir, or create it from `--host` and `--key` on first registration.
2. Register with the CMS and retrieve player settings.
3. Start the internal HTTP server for locally cached resources.
4. Collect required files and schedule data from the CMS.
5. Cache layouts, media, fonts, and generated HTML in the envdir.
6. Send the active schedule to the Qt WebEngine UI.
7. Render layouts full screen and report status/logs back to the CMS when online.

## Key Components

- `src/main.rs`: CLI parsing, startup wiring, backend/frontend thread setup.
- `src/mainloop.rs`: registration, collection loop, schedule checks, commands, offline fallback.
- `src/xmds.rs`: CMS SOAP/XMDS client integration.
- `src/xmr.rs`: real-time message channel for collect-now, screenshot, purge, and command actions.
- `src/resource.rs`: local media cache and downloads.
- `src/schedule.rs`: schedule parsing and active layout selection.
- `src/server.rs`: local embedded HTTP server for cached media and layout files.
- `gui/`: Qt 6 WebEngine wrapper, window sizing, scaling, JavaScript bridge, and splash/icon resources.

## Desktop Integration

The Ubuntu Desktop installer creates a per-user starter script rather than launching the binary directly from the desktop file. The starter handles:

- session environment repair for Wayland/X11 launches;
- `setsid` startup from desktop launchers;
- single-instance locking with `flock`;
- persistent logging;
- `--allow-offline` startup for cached playback.

## Offline Behavior

The backend treats collection failures as non-fatal after startup. With `--allow-offline`, startup can also continue from cached settings and cached schedule data when the CMS is unreachable.
