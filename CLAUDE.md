# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

gardesk is a modular X11 desktop suite written in Rust, consisting of:

- **gar**: Tiling window manager with smart splits, Lua configuration, i3-compatible IPC
- **garbar**: Status bar with Cairo/Pango rendering, async module system
- **garbg**: Wallpaper daemon with slideshows, animations, and remote sources
- **gardm**: Display manager with PAM authentication, X11 server management, and greeter
- **garctl/garbarctl**: CLI control tools for their respective daemons
- **garclip, garlock**: Planned components (not yet implemented)

## Build Commands

Each component is a separate Cargo workspace. Build from within each directory:

```bash
# Window manager
cd gar && cargo build --release

# Status bar
cd garbar && cargo build --release

# Wallpaper daemon
cd garbg && cargo build --release

# Display manager (requires root for PAM)
cd gardm && cargo build --release

# With optional features for garbg:
cd garbg && cargo build --release --features video  # ffmpeg support
cd garbg && cargo build --release --features s3     # AWS S3 support
```

## Testing

```bash
# Run unit tests for a component
cd garbg && cargo test
cd gar && cargo test

# Run specific test
cargo test --manifest-path garbg/Cargo.toml test_name

# Run in nested X server for integration testing
Xephyr -br -ac -noreset -screen 1280x720 :1 &
DISPLAY=:1 cargo run --manifest-path gar/Cargo.toml

# Launch test apps in nested server
DISPLAY=:1 xterm

# Test display manager auth (without X11)
cd gardm && cargo run --bin gardmd -- --test-mode
cd gardm && cargo run --bin test-auth
```

## Architecture

### Monorepo Structure

Each component is an independent Cargo workspace with its own `Cargo.toml`:
- `gar/` - WM workspace with `gar` (main) and `garctl` members
- `garbar/` - Bar workspace with `garbar` and `garbarctl` members
- `garbg/` - Wallpaper workspace with single `garbg` member
- `gardm/` - DM workspace with `gardmd`, `gardm-greeter`, and `gardm-ipc` members

### Shared Patterns

All components share these conventions:

- **X11**: x11rb with RandR for multi-monitor support
- **Config**: Lua via mlua (shared `~/.config/gar/init.lua`) with TOML fallback
- **IPC**: Unix domain sockets with JSON messages at `$XDG_RUNTIME_DIR/{gar,garbar,garbg}.sock`
- **CLI**: clap for argument parsing
- **Logging**: tracing with `RUST_LOG` env filter (e.g., `RUST_LOG=debug cargo run`)
- **Error handling**: thiserror for library errors, anyhow for application errors

### gar (Window Manager)

- `src/core/mod.rs`: `WindowManager` struct - central state machine
- `src/core/tree.rs`: BSP tree for tiling layout with smart splits
- `src/core/workspace.rs`: Workspace management (tiled + floating windows)
- `src/x11/events.rs`: X11 event loop and handlers
- `src/x11/frame.rs`: Title bar frame management
- `src/config/lua.rs`: Lua API (`gar.bind()`, `gar.set()`, `gar.exec()`, `gar.rule()`)
- `src/ipc/i3_compat.rs`: i3 IPC wire protocol for polybar/i3status compatibility
- `src/ipc/i3_server.rs`: i3 IPC server implementation

Configuration file: `~/.config/gar/init.lua`

### garbar (Status Bar)

- `src/modules/mod.rs`: Module trait and registry (workspaces, cpu, memory, battery, datetime, script, tray)
- `src/render/`: Cairo/Pango rendering, layout engine, color/gradient parsing
- `src/daemon/state.rs`: Main event loop, X11 window management
- `src/config/lua.rs`: Reads `gar.bar` table from shared Lua config

Uses tokio async runtime. Modules implement the `Module` trait with `update()` and `output()` methods.

### garbg (Wallpaper Daemon)

- `src/daemon/state.rs`: Main daemon with playlist management, animation loop
- `src/x11/connection.rs`: X11 pixmap management (critical: pixmap lifetime)
- `src/sources/`: Image sources (local, HTTP, GitHub directories, S3)
- `src/media/`: Image loading/scaling, GIF/WebP/APNG animation handling
- `src/cache/`: LRU cache with blake3 hashing
- `src/ipc/gar_client.rs`: Workspace change notifications from gar

**Important**: The daemon must own pixmaps for their lifetime. CLI commands (`next`, `prev`) delegate to the daemon via IPC to avoid pixmap being freed when CLI exits.

Configuration file: `~/.config/garbg/config.toml`

### gardm (Display Manager)

- `gardmd/src/main.rs`: Daemon entry point with X server lifecycle management
- `gardmd/src/auth.rs`: PAM authentication session handling
- `gardmd/src/session.rs`: User session spawning with proper environment
- `gardmd/src/x11.rs`: X server process management
- `gardm-greeter/`: Cairo/X11 graphical greeter with theme support
- `gardm-ipc/`: Shared IPC protocol types

Runs as root, manages X server lifecycle, and spawns user sessions after PAM auth.

## Lua Configuration API (gar)

```lua
-- Settings
gar.set("border_width", 2)
gar.set("gap_inner", 8)

-- Keybindings
gar.bind("mod+return", function() gar.exec("kitty") end)
gar.bind("mod+q", gar.close_window)
gar.bind("mod+1", gar.workspace(1))
gar.bind("mod+h", gar.focus("left"))

-- Window rules
gar.rule({ class = "Firefox" }, { workspace = 2 })

-- Startup commands
gar.exec_once("garbg daemon")
gar.exec_once("garbar")

-- garbar config in same file
gar.bar = {
    height = 28,
    modules_left = { "workspaces" },
    modules_center = { "datetime" },
    modules_right = { "cpu", "memory", "battery" }
}
```

## Systemd Integration

gar-session.sh imports DISPLAY/XAUTHORITY to systemd user session for services like garbg:

```bash
systemctl --user import-environment DISPLAY XAUTHORITY
systemctl --user start gar-session.target
```

## Compositor Integration (picom)

gar generates `~/.config/gar/picom.conf` from Lua settings. Key considerations:

- **Do not use `glx-no-rebind-pixmap = true`** - prevents picom from detecting wallpaper changes
- gar starts picom via `gar-session.sh` before the window manager
- Visual settings (blur, shadows, corners, animations) are configured in `init.lua` via `gar.set()`

## Edition Note

gar uses Rust edition 2024; garbar, garbg, and gardm use edition 2021.
