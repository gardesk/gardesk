#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# gar Desktop Suite Installer
# https://gar.musicsian.com
#
# A modular X11 desktop environment featuring:
#   - gar: Tiling window manager with Lua config
#   - garfield: File manager with dual-pane interface
#   - garterm: GPU-accelerated terminal emulator
#   - garbar: Status bar with Cairo/Pango rendering
#   - gartray: System tray with SNI/XEMBED support
#   - garnotify: Desktop notification daemon
#   - garbg: Wallpaper daemon with animation support
#   - garshot: Screenshot utility with blur selection overlay
#   - garlock: Screen locker with PAM authentication
#   - gardm: Display manager with graphical greeter
#   - garlaunch: Application launcher with fuzzy search
#   - garclip: Clipboard manager with history
#   - gartk: Shared UI toolkit library
#   - garchomp: X11 compositor with GPU rendering
#   - gargears: Configuration GUI for gardesk
#   - gartop: System monitor with resource graphs
#   - garview: Image and document viewer with annotations
#   - garcard: Polkit authentication agent for privileged desktop actions
#
# Usage:
#   curl -fsSL https://gar.musicsian.com/install.sh | bash
#   ./install.sh [--prefix=/path] [--no-deps] [--component=gar,garbar,...]
#
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
# Constants
# ─────────────────────────────────────────────────────────────────────────────

INSTALLER_VERSION="1.0.0"
REPO_URL="https://github.com/gardesk/gardesk"
BRANCH="trunk"

# Installation paths (can be overridden with GAR_PREFIX env var)
PREFIX="${GAR_PREFIX:-/usr/local}"
BIN_DIR="$PREFIX/bin"
SHARE_DIR="$PREFIX/share/gar"
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"
SYSTEMD_SYSTEM_DIR="/usr/lib/systemd/system"

# Build directory
BUILD_DIR="${GAR_BUILD_DIR:-$HOME/.local/src/gardesk}"

# Component flags (set by prompt_components or CLI args)
INSTALL_GAR=false
INSTALL_GARFIELD=false
INSTALL_GARTERM=false
INSTALL_GARBAR=false
INSTALL_GARTRAY=false
INSTALL_GARNOTIFY=false
INSTALL_GARBG=false
INSTALL_GARSHOT=false
INSTALL_GARLOCK=false
INSTALL_GARDM=false
INSTALL_GARLAUNCH=false
INSTALL_GARCLIP=false
INSTALL_GARTK=false
INSTALL_GARCHOMP=false
INSTALL_GARGEARS=false
INSTALL_GARTOP=false
INSTALL_GARVIEW=false
INSTALL_GARCARD=false

# Options
SKIP_DEPS=false
NON_INTERACTIVE=false

# ─────────────────────────────────────────────────────────────────────────────
# Colors and Formatting
# ─────────────────────────────────────────────────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m' # No Color

# ─────────────────────────────────────────────────────────────────────────────
# Utility Functions
# ─────────────────────────────────────────────────────────────────────────────

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_step() {
    echo -e "${CYAN}==>${NC} ${BOLD}$1${NC}"
}

prompt_yes_no() {
    local prompt="$1"
    local default="${2:-y}"

    if [ "$NON_INTERACTIVE" = true ]; then
        return 0
    fi

    local yn
    if [ "$default" = "y" ]; then
        read -p "$prompt [Y/n]: " yn < /dev/tty
        yn="${yn:-y}"
    else
        read -p "$prompt [y/N]: " yn < /dev/tty
        yn="${yn:-n}"
    fi

    case "${yn,,}" in
        y|yes) return 0 ;;
        *) return 1 ;;
    esac
}

check_command() {
    command -v "$1" &> /dev/null
}

# ─────────────────────────────────────────────────────────────────────────────
# System Detection
# ─────────────────────────────────────────────────────────────────────────────

detect_os() {
    case "$(uname -s)" in
        Linux*)  echo "linux" ;;
        Darwin*) echo "macos" ;;
        MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
        *)       echo "unsupported" ;;
    esac
}

detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    elif [ -f /etc/fedora-release ]; then
        echo "fedora"
    elif [ -f /etc/debian_version ]; then
        echo "debian"
    elif [ -f /etc/arch-release ]; then
        echo "arch"
    elif [ -f /etc/gentoo-release ]; then
        echo "gentoo"
    else
        echo "unknown"
    fi
}

detect_arch() {
    case "$(uname -m)" in
        x86_64|amd64)   echo "x64" ;;
        aarch64|arm64)  echo "arm64" ;;
        armv7l)         echo "arm" ;;
        i686|i386)      echo "x86" ;;
        *)              echo "$(uname -m)" ;;
    esac
}

# ─────────────────────────────────────────────────────────────────────────────
# Dependency Installation
# ─────────────────────────────────────────────────────────────────────────────

install_dependencies() {
    local distro="$1"

    log_step "Installing build dependencies for $distro..."

    case "$distro" in
        fedora*|rhel|centos|rocky|alma)
            sudo dnf install -y \
                rust cargo gcc make git \
                libxcb-devel libX11-devel xcb-util-devel \
                cairo-devel pango-devel \
                pam-devel \
                pulseaudio-libs-devel \
                libxkbcommon-devel \
                dbus-devel \
                fontconfig-devel freetype-devel \
                poppler-devel
            ;;

        debian|ubuntu|pop|linuxmint|elementary)
            sudo apt-get update
            sudo apt-get install -y \
                rustc cargo gcc make git \
                libxcb1-dev libx11-dev libxcb-randr0-dev libxcb-xfixes0-dev \
                libcairo2-dev libpango1.0-dev \
                libpam0g-dev \
                libpulse-dev \
                libxkbcommon-dev \
                libdbus-1-dev \
                libfontconfig1-dev libfreetype6-dev \
                libpoppler-glib-dev
            ;;

        arch|manjaro|endeavouros)
            sudo pacman -S --needed --noconfirm \
                rust gcc make git \
                libxcb libx11 xcb-util \
                cairo pango \
                pam \
                libpulse \
                libxkbcommon \
                dbus \
                fontconfig freetype2 \
                poppler-glib
            ;;

        opensuse*|suse)
            sudo zypper install -y \
                rust cargo gcc make git \
                libxcb-devel libX11-devel \
                cairo-devel pango-devel \
                pam-devel \
                libpulse-devel \
                libxkbcommon-devel \
                dbus-1-devel \
                fontconfig-devel freetype2-devel \
                libpoppler-devel
            ;;

        gentoo)
            log_warn "Gentoo detected - please ensure you have the following USE flags enabled:"
            echo "  x11-libs/cairo X"
            echo "  x11-libs/pango X"
            echo ""
            log_info "Installing packages..."
            sudo emerge --ask \
                dev-lang/rust \
                x11-libs/libxcb x11-libs/libX11 \
                x11-libs/cairo x11-libs/pango \
                sys-libs/pam \
                media-sound/pulseaudio \
                x11-libs/libxkbcommon \
                sys-apps/dbus \
                app-text/poppler
            ;;

        void)
            sudo xbps-install -Sy \
                rust cargo gcc make git \
                libxcb-devel libX11-devel \
                cairo-devel pango-devel \
                pam-devel \
                pulseaudio-devel \
                libxkbcommon-devel \
                dbus-devel \
                poppler-devel
            ;;

        alpine)
            sudo apk add \
                rust cargo gcc make git musl-dev \
                libxcb-dev libx11-dev \
                cairo-dev pango-dev \
                linux-pam-dev \
                pulseaudio-dev \
                libxkbcommon-dev \
                dbus-dev \
                poppler-dev
            ;;

        *)
            log_error "Unknown distribution: $distro"
            log_warn "Please install the following dependencies manually:"
            echo ""
            echo "  Build tools: rust, cargo, gcc, make, git"
            echo "  X11: libxcb-dev, libx11-dev, libxcb-randr"
            echo "  Graphics: cairo-dev, pango-dev"
            echo "  Auth: pam-dev"
            echo "  Audio: pulseaudio-dev (optional)"
            echo "  Keyboard: libxkbcommon-dev"
            echo "  IPC: dbus-dev"
            echo "  PDF: poppler-dev (for garview)"
            echo ""
            return 1
            ;;
    esac

    log_info "Dependencies installed successfully"
}

# ─────────────────────────────────────────────────────────────────────────────
# Rust Toolchain
# ─────────────────────────────────────────────────────────────────────────────

ensure_rust() {
    if check_command cargo; then
        local rust_version
        rust_version=$(rustc --version | cut -d' ' -f2)
        log_info "Rust $rust_version found"
        return 0
    fi

    log_step "Installing Rust toolchain..."

    if [ "$NON_INTERACTIVE" = true ]; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    else
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    fi

    # Source cargo environment
    if [ -f "$HOME/.cargo/env" ]; then
        source "$HOME/.cargo/env"
    fi

    if ! check_command cargo; then
        log_error "Failed to install Rust toolchain"
        return 1
    fi

    log_info "Rust installed successfully"
}

# ─────────────────────────────────────────────────────────────────────────────
# Component Selection
# ─────────────────────────────────────────────────────────────────────────────

show_banner() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                                  ║${NC}"
    echo -e "${CYAN}║   ${BOLD}gar Desktop Suite${NC}${CYAN}                                            ║${NC}"
    echo -e "${CYAN}║   ${DIM}Modular X11 desktop environment${NC}${CYAN}                              ║${NC}"
    echo -e "${CYAN}║                                                                  ║${NC}"
    echo -e "${CYAN}║   ${DIM}https://gar.musicsian.com${NC}${CYAN}                                               ║${NC}"
    echo -e "${CYAN}║                                                                  ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

show_component_menu() {
    echo ""
    echo -e "${BOLD}Select components to install:${NC}"
    echo ""
    echo -e "  ${CYAN}1)${NC}  gar        ${DIM}-${NC} Tiling window manager with Lua config ${GREEN}[recommended]${NC}"
    echo -e "  ${CYAN}2)${NC}  garfield   ${DIM}-${NC} File manager with dual-pane interface"
    echo -e "  ${CYAN}3)${NC}  garterm    ${DIM}-${NC} GPU-accelerated terminal emulator"
    echo -e "  ${CYAN}4)${NC}  garbar     ${DIM}-${NC} Status bar with async modules"
    echo -e "  ${CYAN}5)${NC}  gartray    ${DIM}-${NC} System tray with SNI/XEMBED support"
    echo -e "  ${CYAN}6)${NC}  garnotify  ${DIM}-${NC} Desktop notification daemon"
    echo -e "  ${CYAN}7)${NC}  garbg      ${DIM}-${NC} Wallpaper daemon with animations"
    echo -e "  ${CYAN}8)${NC}  garshot    ${DIM}-${NC} Screenshot utility with blur selection"
    echo -e "  ${CYAN}9)${NC}  garlock    ${DIM}-${NC} Screen locker with PAM auth"
    echo -e "  ${CYAN}10)${NC} gardm      ${DIM}-${NC} Display manager ${YELLOW}[requires root]${NC}"
    echo -e "  ${CYAN}11)${NC} garlaunch  ${DIM}-${NC} Application launcher with fuzzy search"
    echo -e "  ${CYAN}12)${NC} garclip    ${DIM}-${NC} Clipboard manager with history"
    echo -e "  ${CYAN}13)${NC} gartk      ${DIM}-${NC} UI toolkit library ${DIM}(dependency)${NC}"
    echo -e "  ${CYAN}14)${NC} garchomp   ${DIM}-${NC} X11 compositor with GPU rendering"
    echo -e "  ${CYAN}15)${NC} gargears   ${DIM}-${NC} Configuration GUI for gardesk"
    echo -e "  ${CYAN}16)${NC} gartop     ${DIM}-${NC} System monitor with resource graphs"
    echo -e "  ${CYAN}17)${NC} garview    ${DIM}-${NC} Image and document viewer with annotations"
    echo -e "  ${CYAN}18)${NC} garcard   ${DIM}-${NC} Polkit authentication agent"
    echo ""
    echo -e "  ${MAGENTA}A)${NC} All components"
    echo -e "  ${MAGENTA}D)${NC} Desktop only (recommended for most users)"
    echo -e "  ${MAGENTA}Q)${NC} Quit"
    echo ""
    echo -e "  ${DIM}Or enter numbers separated by commas/spaces (e.g., 1,3,4,7 or 1 3 4 7)${NC}"
    echo ""
}

prompt_components() {
    if [ "$NON_INTERACTIVE" = true ]; then
        # Default to desktop components in non-interactive mode
        INSTALL_GAR=true
        INSTALL_GARFIELD=true
        INSTALL_GARTERM=true
        INSTALL_GARBAR=true
        INSTALL_GARTRAY=true
        INSTALL_GARNOTIFY=true
        INSTALL_GARBG=true
        INSTALL_GARSHOT=true
        INSTALL_GARLOCK=true
        INSTALL_GARLAUNCH=true
        INSTALL_GARCLIP=true
        INSTALL_GARCHOMP=true
        INSTALL_GARGEARS=true
        INSTALL_GARTOP=true
        INSTALL_GARVIEW=true
        INSTALL_GARCARD=true
        return 0
    fi

    local selection

    show_component_menu
    read -p "Enter selection [D]: " selection < /dev/tty
    selection="${selection:-D}"

    # Reset flags
    INSTALL_GAR=false
    INSTALL_GARFIELD=false
    INSTALL_GARTERM=false
    INSTALL_GARBAR=false
    INSTALL_GARTRAY=false
    INSTALL_GARNOTIFY=false
    INSTALL_GARBG=false
    INSTALL_GARSHOT=false
    INSTALL_GARLOCK=false
    INSTALL_GARDM=false
    INSTALL_GARLAUNCH=false
    INSTALL_GARCLIP=false
    INSTALL_GARTK=false
    INSTALL_GARCHOMP=false
    INSTALL_GARGEARS=false
    INSTALL_GARTOP=false
    INSTALL_GARVIEW=false
    INSTALL_GARCARD=false

    case "${selection^^}" in
        1) INSTALL_GAR=true ;;
        2) INSTALL_GARFIELD=true ;;
        3) INSTALL_GARTERM=true ;;
        4) INSTALL_GARBAR=true ;;
        5) INSTALL_GARTRAY=true ;;
        6) INSTALL_GARNOTIFY=true ;;
        7) INSTALL_GARBG=true ;;
        8) INSTALL_GARSHOT=true ;;
        9) INSTALL_GARLOCK=true ;;
        10) INSTALL_GARDM=true ;;
        11) INSTALL_GARLAUNCH=true ;;
        12) INSTALL_GARCLIP=true ;;
        13) INSTALL_GARTK=true ;;
        14) INSTALL_GARCHOMP=true ;;
        15) INSTALL_GARGEARS=true ;;
        16) INSTALL_GARTOP=true ;;
        17) INSTALL_GARVIEW=true ;;
        18) INSTALL_GARCARD=true ;;
        A|ALL)
            INSTALL_GAR=true
            INSTALL_GARFIELD=true
            INSTALL_GARTERM=true
            INSTALL_GARBAR=true
            INSTALL_GARTRAY=true
            INSTALL_GARNOTIFY=true
            INSTALL_GARBG=true
            INSTALL_GARSHOT=true
            INSTALL_GARLOCK=true
            INSTALL_GARDM=true
            INSTALL_GARLAUNCH=true
            INSTALL_GARCLIP=true
            INSTALL_GARTK=true
            INSTALL_GARCHOMP=true
            INSTALL_GARGEARS=true
            INSTALL_GARTOP=true
            INSTALL_GARVIEW=true
            INSTALL_GARCARD=true
            ;;
        D|DESKTOP)
            INSTALL_GAR=true
            INSTALL_GARFIELD=true
            INSTALL_GARTERM=true
            INSTALL_GARBAR=true
            INSTALL_GARTRAY=true
            INSTALL_GARNOTIFY=true
            INSTALL_GARBG=true
            INSTALL_GARSHOT=true
            INSTALL_GARLOCK=true
            INSTALL_GARLAUNCH=true
            INSTALL_GARCLIP=true
            INSTALL_GARCHOMP=true
            INSTALL_GARGEARS=true
            INSTALL_GARTOP=true
            INSTALL_GARVIEW=true
            INSTALL_GARCARD=true
            ;;
        Q|QUIT)
            log_info "Installation cancelled"
            exit 0
            ;;
        *)
            # Parse comma-separated or space-separated list like "1,2,4" or "1 2 4"
            for num in ${selection//,/ }; do
                case "$num" in
                    1) INSTALL_GAR=true ;;
                    2) INSTALL_GARFIELD=true ;;
                    3) INSTALL_GARTERM=true ;;
                    4) INSTALL_GARBAR=true ;;
                    5) INSTALL_GARTRAY=true ;;
                    6) INSTALL_GARNOTIFY=true ;;
                    7) INSTALL_GARBG=true ;;
                    8) INSTALL_GARSHOT=true ;;
                    9) INSTALL_GARLOCK=true ;;
                    10) INSTALL_GARDM=true ;;
                    11) INSTALL_GARLAUNCH=true ;;
                    12) INSTALL_GARCLIP=true ;;
                    13) INSTALL_GARTK=true ;;
                    14) INSTALL_GARCHOMP=true ;;
                    15) INSTALL_GARGEARS=true ;;
                    16) INSTALL_GARTOP=true ;;
                    17) INSTALL_GARVIEW=true ;;
                    18) INSTALL_GARCARD=true ;;
                esac
            done
            ;;
    esac

    # Ensure at least one component is selected
    if [ "$INSTALL_GAR" = false ] && [ "$INSTALL_GARFIELD" = false ] && \
       [ "$INSTALL_GARTERM" = false ] && [ "$INSTALL_GARBAR" = false ] && \
       [ "$INSTALL_GARTRAY" = false ] && [ "$INSTALL_GARNOTIFY" = false ] && \
       [ "$INSTALL_GARBG" = false ] && [ "$INSTALL_GARSHOT" = false ] && \
       [ "$INSTALL_GARLOCK" = false ] && [ "$INSTALL_GARDM" = false ] && \
       [ "$INSTALL_GARLAUNCH" = false ] && [ "$INSTALL_GARCLIP" = false ] && \
       [ "$INSTALL_GARTK" = false ] && [ "$INSTALL_GARCHOMP" = false ] && \
       [ "$INSTALL_GARGEARS" = false ] && [ "$INSTALL_GARTOP" = false ] && \
       [ "$INSTALL_GARVIEW" = false ] && [ "$INSTALL_GARCARD" = false ]; then
        log_error "No components selected"
        return 1
    fi

    # Auto-select gartk for components that depend on it
    if [ "$INSTALL_GARFIELD" = true ] && [ "$INSTALL_GARTK" = false ]; then
        log_info "garfield requires gartk, adding to installation"
        INSTALL_GARTK=true
    fi

    if [ "$INSTALL_GARTERM" = true ] && [ "$INSTALL_GARTK" = false ]; then
        log_info "garterm requires gartk, adding to installation"
        INSTALL_GARTK=true
    fi

    if [ "$INSTALL_GARTRAY" = true ] && [ "$INSTALL_GARTK" = false ]; then
        log_info "gartray requires gartk, adding to installation"
        INSTALL_GARTK=true
    fi

    if [ "$INSTALL_GARLAUNCH" = true ] && [ "$INSTALL_GARTK" = false ]; then
        log_info "garlaunch requires gartk, adding to installation"
        INSTALL_GARTK=true
    fi

    if [ "$INSTALL_GARCLIP" = true ] && [ "$INSTALL_GARTK" = false ]; then
        log_info "garclip-picker requires gartk, adding to installation"
        INSTALL_GARTK=true
    fi

    if [ "$INSTALL_GARGEARS" = true ] && [ "$INSTALL_GARTK" = false ]; then
        log_info "gargears requires gartk, adding to installation"
        INSTALL_GARTK=true
    fi

    if [ "$INSTALL_GARTOP" = true ] && [ "$INSTALL_GARTK" = false ]; then
        log_info "gartop requires gartk, adding to installation"
        INSTALL_GARTK=true
    fi

    if [ "$INSTALL_GARVIEW" = true ] && [ "$INSTALL_GARTK" = false ]; then
        log_info "garview requires gartk, adding to installation"
        INSTALL_GARTK=true
    fi
}

show_selection_summary() {
    echo ""
    log_info "Components to install:"

    [ "$INSTALL_GAR" = true ] && echo -e "  ${GREEN}•${NC} gar (window manager)"
    [ "$INSTALL_GARFIELD" = true ] && echo -e "  ${GREEN}•${NC} garfield (file manager)"
    [ "$INSTALL_GARTERM" = true ] && echo -e "  ${GREEN}•${NC} garterm (terminal emulator)"
    [ "$INSTALL_GARBAR" = true ] && echo -e "  ${GREEN}•${NC} garbar (status bar)"
    [ "$INSTALL_GARTRAY" = true ] && echo -e "  ${GREEN}•${NC} gartray (system tray)"
    [ "$INSTALL_GARNOTIFY" = true ] && echo -e "  ${GREEN}•${NC} garnotify (notification daemon)"
    [ "$INSTALL_GARBG" = true ] && echo -e "  ${GREEN}•${NC} garbg (wallpaper daemon)"
    [ "$INSTALL_GARSHOT" = true ] && echo -e "  ${GREEN}•${NC} garshot (screenshot utility)"
    [ "$INSTALL_GARLOCK" = true ] && echo -e "  ${GREEN}•${NC} garlock (screen locker)"
    [ "$INSTALL_GARDM" = true ] && echo -e "  ${YELLOW}•${NC} gardm (display manager)"
    [ "$INSTALL_GARLAUNCH" = true ] && echo -e "  ${GREEN}•${NC} garlaunch (application launcher)"
    [ "$INSTALL_GARCLIP" = true ] && echo -e "  ${GREEN}•${NC} garclip (clipboard manager)"
    [ "$INSTALL_GARTK" = true ] && echo -e "  ${DIM}•${NC} gartk (UI toolkit library)"
    [ "$INSTALL_GARCHOMP" = true ] && echo -e "  ${GREEN}•${NC} garchomp (X11 compositor)"
    [ "$INSTALL_GARGEARS" = true ] && echo -e "  ${GREEN}•${NC} gargears (configuration GUI)"
    [ "$INSTALL_GARTOP" = true ] && echo -e "  ${GREEN}•${NC} gartop (system monitor)"
    [ "$INSTALL_GARVIEW" = true ] && echo -e "  ${GREEN}•${NC} garview (image & document viewer)"
    [ "$INSTALL_GARCARD" = true ] && echo -e "  ${GREEN}•${NC} garcard (polkit authentication agent)"

    echo ""
    log_info "Installation prefix: $PREFIX"
    log_info "Build directory: $BUILD_DIR"
    echo ""
}

# ─────────────────────────────────────────────────────────────────────────────
# Source Code Management
# ─────────────────────────────────────────────────────────────────────────────

fetch_source() {
    log_step "Fetching gar source code..."

    mkdir -p "$(dirname "$BUILD_DIR")"

    if [ -d "$BUILD_DIR/.git" ]; then
        log_info "Updating existing source..."
        cd "$BUILD_DIR"
        git fetch origin
        git checkout "$BRANCH"
        git pull origin "$BRANCH"
        git submodule update --init --recursive
    else
        if [ -d "$BUILD_DIR" ]; then
            log_warn "Directory exists but is not a git repo, removing..."
            rm -rf "$BUILD_DIR"
        fi

        log_info "Cloning repository..."
        git clone --branch "$BRANCH" --recurse-submodules "$REPO_URL" "$BUILD_DIR"
    fi

    cd "$BUILD_DIR"
    log_info "Source ready at $BUILD_DIR"
}

# ─────────────────────────────────────────────────────────────────────────────
# Component Installers
# ─────────────────────────────────────────────────────────────────────────────

install_gar() {
    log_step "Building gar (window manager)..."

    cd "$BUILD_DIR/gar"
    cargo build --release --workspace

    log_info "Installing gar binaries to $BIN_DIR..."
    sudo install -Dm755 target/release/gar "$BIN_DIR/gar"
    sudo install -Dm755 target/release/garctl "$BIN_DIR/garctl"

    # Install session files
    sudo mkdir -p "$SHARE_DIR"
    sudo install -Dm755 gar-session.sh "$SHARE_DIR/gar-session.sh"

    # Update gar-session.sh to use installed binary path
    sudo sed -i "s|exec .*gar$|exec \"$BIN_DIR/gar\"|" "$SHARE_DIR/gar-session.sh"

    # Install XSession desktop entry
    if [ -d /usr/share/xsessions ]; then
        log_info "Installing XSession entry..."
        cat << EOF | sudo tee /usr/share/xsessions/gar.desktop > /dev/null
[Desktop Entry]
Name=gar
Comment=gar tiling window manager
Exec=$SHARE_DIR/gar-session.sh
Type=XSession
DesktopNames=gar
EOF
    fi

    # Create user config directory and install default config
    mkdir -p "$HOME/.config/gar"
    if [ ! -f "$HOME/.config/gar/init.lua" ]; then
        if [ -f "$BUILD_DIR/config/gar/init.lua" ]; then
            log_info "Installing default configuration..."
            install -m644 "$BUILD_DIR/config/gar/init.lua" "$HOME/.config/gar/init.lua"
        fi
    else
        log_warn "Config exists at ~/.config/gar/init.lua, not overwriting"
    fi

    echo -e "${GREEN}  ✓ gar installed successfully${NC}"
}

install_garfield() {
    log_step "Building garfield (file manager)..."

    cd "$BUILD_DIR/garfield"
    cargo build --release

    log_info "Installing garfield binaries to $BIN_DIR..."
    sudo install -Dm755 target/release/garfield "$BIN_DIR/garfield"
    sudo install -Dm755 target/release/garfieldctl "$BIN_DIR/garfieldctl"

    # Create user config directory
    mkdir -p "$HOME/.config/garfield"

    echo -e "${GREEN}  ✓ garfield installed successfully${NC}"
    log_info "  Bind to a key: gar.key({ gar.mod, \"e\", gar.spawn(\"garfield\") })"
}

install_garterm() {
    log_step "Building garterm (terminal emulator)..."

    cd "$BUILD_DIR/garterm"
    cargo build --release

    log_info "Installing garterm binaries to $BIN_DIR..."
    sudo install -Dm755 target/release/garterm "$BIN_DIR/garterm"
    sudo install -Dm755 target/release/gartermctl "$BIN_DIR/gartermctl"

    # Create user config directory
    mkdir -p "$HOME/.config/garterm"

    # Install default config if not present
    if [ ! -f "$HOME/.config/garterm/config.toml" ]; then
        if [ -f "$BUILD_DIR/config/garterm/config.toml" ]; then
            log_info "Installing default configuration..."
            install -m644 "$BUILD_DIR/config/garterm/config.toml" "$HOME/.config/garterm/config.toml"
        fi
    else
        log_warn "Config exists at ~/.config/garterm/config.toml, not overwriting"
    fi

    echo -e "${GREEN}  ✓ garterm installed successfully${NC}"
    log_info "  Default terminal: set gar.terminal in ~/.config/gar/init.lua"
    log_info "  Bind to a key: gar.key({ gar.mod, \"Return\", gar.spawn(\"garterm\") })"
}

install_garbar() {
    log_step "Building garbar (status bar)..."

    cd "$BUILD_DIR/garbar"
    cargo build --release

    log_info "Installing garbar binaries to $BIN_DIR..."
    sudo install -Dm755 target/release/garbar "$BIN_DIR/garbar"
    sudo install -Dm755 target/release/garbarctl "$BIN_DIR/garbarctl"

    # Create user config directory
    mkdir -p "$HOME/.config/garbar"
    if [ ! -f "$HOME/.config/garbar/config.toml" ]; then
        if [ -f "$BUILD_DIR/config/garbar/config.toml" ]; then
            log_info "Installing default configuration..."
            install -m644 "$BUILD_DIR/config/garbar/config.toml" "$HOME/.config/garbar/config.toml"
        fi
    else
        log_warn "Config exists at ~/.config/garbar/config.toml, not overwriting"
    fi

    echo -e "${GREEN}  ✓ garbar installed successfully${NC}"
}

install_gartray() {
    log_step "Building gartray (system tray)..."

    cd "$BUILD_DIR/gartray"
    cargo build --release --workspace

    log_info "Installing gartray binaries to $BIN_DIR..."
    sudo install -Dm755 target/release/gartray "$BIN_DIR/gartray"
    sudo install -Dm755 target/release/gartrayctl "$BIN_DIR/gartrayctl"

    # Create user config directory
    mkdir -p "$HOME/.config/gartray"

    # Install default config if not present
    if [ ! -f "$HOME/.config/gartray/config.toml" ]; then
        if [ -f "$BUILD_DIR/config/gartray/config.toml" ]; then
            log_info "Installing default configuration..."
            install -m644 "$BUILD_DIR/config/gartray/config.toml" "$HOME/.config/gartray/config.toml"
        fi
    else
        log_warn "Config exists at ~/.config/gartray/config.toml, not overwriting"
    fi

    echo -e "${GREEN}  ✓ gartray installed successfully${NC}"
    log_info "  Integrates with garbar tray module"
    log_info "  Use gartrayctl to control from scripts"
}

install_garnotify() {
    log_step "Building garnotify (notification daemon)..."

    cd "$BUILD_DIR/garnotify"
    cargo build --release --workspace

    log_info "Installing garnotify binaries to $BIN_DIR..."
    sudo install -Dm755 target/release/garnotify "$BIN_DIR/garnotify"
    sudo install -Dm755 target/release/garnotifyctl "$BIN_DIR/garnotifyctl"

    # Create user config directory
    mkdir -p "$HOME/.config/garnotify"

    # Install default config if not present
    if [ ! -f "$HOME/.config/garnotify/config.toml" ]; then
        if [ -f "$BUILD_DIR/config/garnotify/config.toml" ]; then
            log_info "Installing default configuration..."
            install -m644 "$BUILD_DIR/config/garnotify/config.toml" "$HOME/.config/garnotify/config.toml"
        fi
    else
        log_warn "Config exists at ~/.config/garnotify/config.toml, not overwriting"
    fi

    echo -e "${GREEN}  ✓ garnotify installed successfully${NC}"
    log_info "  Auto-starts with gar when gar.notification table is configured"
    log_info "  Control via: garnotifyctl pause|resume|history"
}

install_garbg() {
    log_step "Building garbg (wallpaper daemon)..."

    cd "$BUILD_DIR/garbg"
    cargo build --release

    log_info "Installing garbg binary to $BIN_DIR..."
    sudo install -Dm755 target/release/garbg "$BIN_DIR/garbg"

    # Install user systemd service
    log_info "Installing systemd user service..."
    mkdir -p "$SYSTEMD_USER_DIR"

    cat << EOF > "$SYSTEMD_USER_DIR/garbg.service"
[Unit]
Description=garbg wallpaper daemon
Documentation=https://gar.musicsian.com
After=graphical-session.target
PartOf=graphical-session.target

[Service]
Type=simple
ExecStart=$BIN_DIR/garbg daemon
Restart=on-failure
RestartSec=3

[Install]
WantedBy=graphical-session.target
EOF

    systemctl --user daemon-reload

    # Create user config directory
    mkdir -p "$HOME/.config/garbg"
    if [ ! -f "$HOME/.config/garbg/config.toml" ]; then
        if [ -f "$BUILD_DIR/config/garbg/config.toml" ]; then
            log_info "Installing default configuration..."
            install -m644 "$BUILD_DIR/config/garbg/config.toml" "$HOME/.config/garbg/config.toml"
        fi
    fi

    echo -e "${GREEN}  ✓ garbg installed successfully${NC}"
    log_info "  Enable with: systemctl --user enable --now garbg"
}

install_garshot() {
    log_step "Building garshot (screenshot utility)..."

    cd "$BUILD_DIR/garshot"
    cargo build --release

    log_info "Installing garshot binaries to $BIN_DIR..."
    sudo install -Dm755 target/release/garshot "$BIN_DIR/garshot"
    sudo install -Dm755 target/release/garshotctl "$BIN_DIR/garshotctl"

    # Create user config directory
    mkdir -p "$HOME/.config/garshot"
    if [ ! -f "$HOME/.config/garshot/config.toml" ]; then
        if [ -f "$BUILD_DIR/config/garshot/config.toml" ]; then
            log_info "Installing default configuration..."
            install -m644 "$BUILD_DIR/config/garshot/config.toml" "$HOME/.config/garshot/config.toml"
        fi
    fi

    # Ensure screenshots directory exists
    mkdir -p "$HOME/Pictures/Screenshots"

    echo -e "${GREEN}  ✓ garshot installed successfully${NC}"
    log_info "  Keybinds: Ctrl+Shift+4 (region), Ctrl+Shift+5 (screen), Ctrl+Shift+6 (window)"
}

install_garlock() {
    log_step "Building garlock (screen locker)..."

    cd "$BUILD_DIR/garlock"
    cargo build --release

    log_info "Installing garlock binary to $BIN_DIR..."
    sudo install -Dm755 target/release/garlock "$BIN_DIR/garlock"

    # Install PAM configuration
    if [ ! -f /etc/pam.d/garlock ]; then
        log_info "Installing PAM configuration..."
        cat << 'EOF' | sudo tee /etc/pam.d/garlock > /dev/null
#%PAM-1.0
auth       include      system-auth
account    include      system-auth
EOF
    else
        log_warn "PAM config exists at /etc/pam.d/garlock, not overwriting"
    fi

    # Create default config
    mkdir -p "$HOME/.config/garlock"
    if [ ! -f "$HOME/.config/garlock/config.toml" ]; then
        if [ -f "$BUILD_DIR/config/garlock/config.toml" ]; then
            log_info "Installing default configuration..."
            install -m644 "$BUILD_DIR/config/garlock/config.toml" "$HOME/.config/garlock/config.toml"
        fi
    fi

    echo -e "${GREEN}  ✓ garlock installed successfully${NC}"
}

install_gardm() {
    log_step "Building gardm (display manager)..."

    cd "$BUILD_DIR/gardm"
    cargo build --release -p gardmd -p gardm-greeter

    log_warn "gardm requires system-wide installation..."

    sudo install -Dm755 target/release/gardmd /usr/bin/gardmd
    sudo install -Dm755 target/release/gardm-greeter /usr/bin/gardm-greeter

    # Create directories
    sudo mkdir -p /etc/gardm
    sudo mkdir -p /usr/share/gardm/backgrounds

    # Install PAM configuration
    if [ -f etc/pam.d/gardm ]; then
        log_info "Installing PAM configuration..."
        sudo install -Dm644 etc/pam.d/gardm /etc/pam.d/gardm
    fi

    # Install systemd service
    if [ -f etc/gardm.service ]; then
        log_info "Installing systemd service..."
        sudo install -Dm644 etc/gardm.service "$SYSTEMD_SYSTEM_DIR/gardm.service"
    fi

    # Install default config
    if [ ! -f /etc/gardm/config.toml ] && [ -f etc/config.toml ]; then
        log_info "Installing default configuration..."
        sudo install -Dm644 etc/config.toml /etc/gardm/config.toml
    fi

    # Create sysconfig for environment overrides
    if [ ! -f /etc/sysconfig/gardm ]; then
        sudo mkdir -p /etc/sysconfig
        echo "# Environment variables for gardm" | sudo tee /etc/sysconfig/gardm > /dev/null
    fi

    sudo systemctl daemon-reload

    echo -e "${GREEN}  ✓ gardm installed successfully${NC}"
    log_info "  To enable gardm as your display manager:"
    log_info "    sudo systemctl disable <current-dm>  # sddm, gdm, lightdm, etc."
    log_info "    sudo systemctl enable gardm"
    log_info "    sudo reboot"
    log_warn "  Keep a TTY login ready as backup (Ctrl+Alt+F2)"
}

install_gartk() {
    log_step "Building gartk (UI toolkit)..."

    cd "$BUILD_DIR/gartk"
    cargo build --release

    # gartk is a library crate, no binaries to install
    # It will be built as part of garlaunch's dependencies
    # We just verify it compiles

    echo -e "${GREEN}  ✓ gartk built successfully${NC}"
    log_info "  gartk is a library used by garlaunch"
}

install_garlaunch() {
    log_step "Building garlaunch (application launcher)..."

    cd "$BUILD_DIR/garlaunch"
    cargo build --release

    log_info "Installing garlaunch binaries to $BIN_DIR..."
    sudo install -Dm755 target/release/garlaunch "$BIN_DIR/garlaunch"
    sudo install -Dm755 target/release/garlaunchctl "$BIN_DIR/garlaunchctl"

    # Create user config directory (garlaunch uses defaults internally)
    mkdir -p "$HOME/.config/garlaunch"

    echo -e "${GREEN}  ✓ garlaunch installed successfully${NC}"
    log_info "  Bind to a key: gar.key({ gar.mod, \"d\", gar.spawn(\"garlaunch\") })"
}

install_garclip() {
    log_step "Building garclip (clipboard manager)..."

    cd "$BUILD_DIR/garclip"
    cargo build --release

    log_info "Installing garclip binaries to $BIN_DIR..."
    sudo install -Dm755 target/release/garclip "$BIN_DIR/garclip"
    sudo install -Dm755 target/release/garclipctl "$BIN_DIR/garclipctl"
    sudo install -Dm755 target/release/garclip-picker "$BIN_DIR/garclip-picker"

    # Install user systemd service
    log_info "Installing systemd user service..."
    mkdir -p "$SYSTEMD_USER_DIR"

    cat << EOF > "$SYSTEMD_USER_DIR/garclip.service"
[Unit]
Description=garclip clipboard manager
Documentation=https://gar.musicsian.com
After=graphical-session.target
PartOf=graphical-session.target

[Service]
Type=simple
ExecStart=$BIN_DIR/garclip daemon
Restart=on-failure
RestartSec=3

[Install]
WantedBy=graphical-session.target
EOF

    systemctl --user daemon-reload

    # Create user config directory (garclip uses defaults internally)
    mkdir -p "$HOME/.config/garclip"

    echo -e "${GREEN}  ✓ garclip installed successfully${NC}"
    log_info "  Enable with: systemctl --user enable --now garclip"
    log_info "  Bind picker to a key in ~/.config/gar/init.lua"
}

install_garchomp() {
    log_step "Building garchomp (X11 compositor)..."

    cd "$BUILD_DIR/garchomp"
    cargo build --release

    log_info "Installing garchomp binaries to $BIN_DIR..."
    sudo install -Dm755 target/release/garchomp "$BIN_DIR/garchomp"
    sudo install -Dm755 target/release/garchompctl "$BIN_DIR/garchompctl"

    # Install user systemd service
    log_info "Installing systemd user service..."
    mkdir -p "$SYSTEMD_USER_DIR"

    cat << EOF > "$SYSTEMD_USER_DIR/garchomp.service"
[Unit]
Description=garchomp X11 compositor
Documentation=https://gar.musicsian.com
After=graphical-session.target
PartOf=graphical-session.target
Conflicts=picom.service

[Service]
Type=simple
ExecStart=$BIN_DIR/garchomp
Restart=on-failure
RestartSec=3

[Install]
WantedBy=graphical-session.target
EOF

    systemctl --user daemon-reload

    # Create user config directory
    mkdir -p "$HOME/.config/garchomp"
    if [ ! -f "$HOME/.config/garchomp/init.lua" ]; then
        if [ -f "$BUILD_DIR/config/garchomp/init.lua" ]; then
            log_info "Installing default configuration..."
            install -m644 "$BUILD_DIR/config/garchomp/init.lua" "$HOME/.config/garchomp/init.lua"
        fi
    else
        log_warn "Config exists at ~/.config/garchomp/init.lua, not overwriting"
    fi

    echo -e "${GREEN}  ✓ garchomp installed successfully${NC}"
    log_info "  Enable with: systemctl --user enable --now garchomp"
    log_info "  Or set gar.set(\"compositor\", \"garchomp\") in init.lua"
}

install_gargears() {
    log_step "Building gargears (configuration GUI)..."

    cd "$BUILD_DIR/gargears"
    cargo build --release

    log_info "Installing gargears binaries to $BIN_DIR..."
    sudo install -Dm755 target/release/gargears "$BIN_DIR/gargears"
    sudo install -Dm755 target/release/gargearsctl "$BIN_DIR/gargearsctl"

    # Create user config directory
    mkdir -p "$HOME/.config/gargears"

    echo -e "${GREEN}  ✓ gargears installed successfully${NC}"
    log_info "  Launch with: gargears"
    log_info "  Or run as daemon: gargears --daemon"
}

install_gartop() {
    log_step "Building gartop (system monitor)..."

    cd "$BUILD_DIR/gartop"
    cargo build --release

    log_info "Installing gartop binaries to $BIN_DIR..."
    sudo install -Dm755 target/release/gartop "$BIN_DIR/gartop"
    sudo install -Dm755 target/release/gartopctl "$BIN_DIR/gartopctl"

    # Install user systemd service for daemon mode
    log_info "Installing systemd user service..."
    mkdir -p "$SYSTEMD_USER_DIR"

    cat << EOF > "$SYSTEMD_USER_DIR/gartop.service"
[Unit]
Description=gartop system monitor daemon
Documentation=https://gar.musicsian.com
After=graphical-session.target
PartOf=graphical-session.target

[Service]
Type=simple
ExecStart=$BIN_DIR/gartop --daemon
Restart=on-failure
RestartSec=3

[Install]
WantedBy=graphical-session.target
EOF

    systemctl --user daemon-reload

    # Create user config directory
    mkdir -p "$HOME/.config/gartop"
    if [ ! -f "$HOME/.config/gartop/config.toml" ]; then
        if [ -f "$BUILD_DIR/config/gartop/config.toml" ]; then
            log_info "Installing default configuration..."
            install -m644 "$BUILD_DIR/config/gartop/config.toml" "$HOME/.config/gartop/config.toml"
        fi
    else
        log_warn "Config exists at ~/.config/gartop/config.toml, not overwriting"
    fi

    echo -e "${GREEN}  ✓ gartop installed successfully${NC}"
    log_info "  Launch GUI with: gartop"
    log_info "  Enable daemon: systemctl --user enable --now gartop"
    log_info "  Control via: gartopctl cpu|memory|network|processes"
}

install_garview() {
    log_step "Building garview (image & document viewer)..."

    cd "$BUILD_DIR/garview"
    cargo build --release

    log_info "Installing garview binaries to $BIN_DIR..."
    sudo install -Dm755 target/release/garview "$BIN_DIR/garview"
    sudo install -Dm755 target/release/garviewctl "$BIN_DIR/garviewctl"

    # Create user config directory
    mkdir -p "$HOME/.config/garview"
    if [ ! -f "$HOME/.config/garview/config.toml" ]; then
        if [ -f "$BUILD_DIR/config/garview/config.toml" ]; then
            log_info "Installing default configuration..."
            install -m644 "$BUILD_DIR/config/garview/config.toml" "$HOME/.config/garview/config.toml"
        fi
    else
        log_warn "Config exists at ~/.config/garview/config.toml, not overwriting"
    fi

    echo -e "${GREEN}  ✓ garview installed successfully${NC}"
    log_info "  Open files with: garview /path/to/file"
    log_info "  Control via: garviewctl open|next|prev|zoom-in|zoom-out|info"
}

install_garcard() {
    log_step "Building garcard (polkit authentication agent)..."

    cd "$BUILD_DIR/garcard"
    cargo build --release --workspace

    log_info "Installing garcard binaries to $BIN_DIR..."
    sudo install -Dm755 target/release/garcard "$BIN_DIR/garcard"
    sudo install -Dm755 target/release/garcardctl "$BIN_DIR/garcardctl"

    # Install user systemd service
    log_info "Installing systemd user service..."
    mkdir -p "$SYSTEMD_USER_DIR"

    cat << EOF > "$SYSTEMD_USER_DIR/garcard.service"
[Unit]
Description=garcard polkit auth agent
Documentation=https://github.com/gardesk/gardesk
After=graphical-session.target
PartOf=graphical-session.target

[Service]
Type=simple
ExecStart=$BIN_DIR/garcard daemon
Restart=on-failure
RestartSec=2

[Install]
WantedBy=graphical-session.target
EOF

    systemctl --user daemon-reload

    # Create user config directory
    mkdir -p "$HOME/.config/garcard"
    if [ ! -f "$HOME/.config/garcard/config.toml" ]; then
        if [ -f "$BUILD_DIR/config/garcard/config.toml" ]; then
            log_info "Installing default configuration..."
            install -m644 "$BUILD_DIR/config/garcard/config.toml" "$HOME/.config/garcard/config.toml"
        fi
    else
        log_warn "Config exists at ~/.config/garcard/config.toml, not overwriting"
    fi

    echo -e "${GREEN}  ✓ garcard installed successfully${NC}"
    log_info "  Enable daemon: systemctl --user enable --now garcard"
    log_info "  Control via: garcardctl status|diagnose|auth-summary|temp-list|quit"
}

# ─────────────────────────────────────────────────────────────────────────────
# PATH Setup
# ─────────────────────────────────────────────────────────────────────────────

setup_path() {
    # Check if BIN_DIR is already in PATH
    if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
        log_info "Adding $BIN_DIR to PATH..."

        local shell_rc=""
        case "$SHELL" in
            */bash) shell_rc="$HOME/.bashrc" ;;
            */zsh)  shell_rc="$HOME/.zshrc" ;;
            */fish) shell_rc="$HOME/.config/fish/config.fish" ;;
        esac

        if [ -n "$shell_rc" ] && [ -f "$shell_rc" ]; then
            if ! grep -q "export PATH=\"$BIN_DIR:\$PATH\"" "$shell_rc" 2>/dev/null; then
                echo "" >> "$shell_rc"
                echo "# gar Desktop Suite" >> "$shell_rc"
                echo "export PATH=\"$BIN_DIR:\$PATH\"" >> "$shell_rc"
                log_info "Added to $shell_rc"
            fi
        fi

        # Also export for current session
        export PATH="$BIN_DIR:$PATH"
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --prefix=*)
                PREFIX="${1#*=}"
                BIN_DIR="$PREFIX/bin"
                SHARE_DIR="$PREFIX/share/gar"
                shift
                ;;
            --no-deps)
                SKIP_DEPS=true
                shift
                ;;
            --non-interactive|-y)
                NON_INTERACTIVE=true
                shift
                ;;
            --component=*|--components=*)
                local components="${1#*=}"
                for comp in ${components//,/ }; do
                    case "$comp" in
                        gar) INSTALL_GAR=true ;;
                        garfield) INSTALL_GARFIELD=true ;;
                        garterm) INSTALL_GARTERM=true ;;
                        garbar) INSTALL_GARBAR=true ;;
                        gartray) INSTALL_GARTRAY=true ;;
                        garnotify) INSTALL_GARNOTIFY=true ;;
                        garbg) INSTALL_GARBG=true ;;
                        garshot) INSTALL_GARSHOT=true ;;
                        garlock) INSTALL_GARLOCK=true ;;
                        gardm) INSTALL_GARDM=true ;;
                        garlaunch) INSTALL_GARLAUNCH=true ;;
                        garclip) INSTALL_GARCLIP=true ;;
                        gartk) INSTALL_GARTK=true ;;
                        garchomp) INSTALL_GARCHOMP=true ;;
                        gargears) INSTALL_GARGEARS=true ;;
                        gartop) INSTALL_GARTOP=true ;;
                        garview) INSTALL_GARVIEW=true ;;
                        garcard) INSTALL_GARCARD=true ;;
                        all)
                            INSTALL_GAR=true
                            INSTALL_GARFIELD=true
                            INSTALL_GARTERM=true
                            INSTALL_GARBAR=true
                            INSTALL_GARTRAY=true
                            INSTALL_GARNOTIFY=true
                            INSTALL_GARBG=true
                            INSTALL_GARSHOT=true
                            INSTALL_GARLOCK=true
                            INSTALL_GARDM=true
                            INSTALL_GARLAUNCH=true
                            INSTALL_GARCLIP=true
                            INSTALL_GARTK=true
                            INSTALL_GARCHOMP=true
                            INSTALL_GARGEARS=true
                            INSTALL_GARTOP=true
                            INSTALL_GARVIEW=true
                            INSTALL_GARCARD=true
                            ;;
                        desktop)
                            INSTALL_GAR=true
                            INSTALL_GARFIELD=true
                            INSTALL_GARTERM=true
                            INSTALL_GARBAR=true
                            INSTALL_GARTRAY=true
                            INSTALL_GARNOTIFY=true
                            INSTALL_GARBG=true
                            INSTALL_GARSHOT=true
                            INSTALL_GARLOCK=true
                            INSTALL_GARLAUNCH=true
                            INSTALL_GARCLIP=true
                            INSTALL_GARCHOMP=true
                            INSTALL_GARGEARS=true
                            INSTALL_GARTOP=true
                            INSTALL_GARVIEW=true
                            INSTALL_GARCARD=true
                            ;;
                    esac
                done
                # Auto-add gartk for components that depend on it
                if [ "$INSTALL_GARFIELD" = true ]; then
                    INSTALL_GARTK=true
                fi
                if [ "$INSTALL_GARTERM" = true ]; then
                    INSTALL_GARTK=true
                fi
                if [ "$INSTALL_GARTRAY" = true ]; then
                    INSTALL_GARTK=true
                fi
                if [ "$INSTALL_GARLAUNCH" = true ]; then
                    INSTALL_GARTK=true
                fi
                if [ "$INSTALL_GARCLIP" = true ]; then
                    INSTALL_GARTK=true
                fi
                if [ "$INSTALL_GARGEARS" = true ]; then
                    INSTALL_GARTK=true
                fi
                if [ "$INSTALL_GARTOP" = true ]; then
                    INSTALL_GARTK=true
                fi
                if [ "$INSTALL_GARVIEW" = true ]; then
                    INSTALL_GARTK=true
                fi
                shift
                ;;
            --help|-h)
                echo "gar Desktop Suite Installer v$INSTALLER_VERSION"
                echo ""
                echo "Usage: $0 [options]"
                echo ""
                echo "Options:"
                echo "  --prefix=PATH       Installation prefix (default: /usr/local)"
                echo "  --no-deps           Skip dependency installation"
                echo "  --non-interactive   Non-interactive mode (accept defaults)"
                echo "  --component=LIST    Comma-separated components to install"
                echo "                      Components: gar,garfield,garterm,garbar,gartray,garnotify,"
                echo "                                  garbg,garshot,garlock,gardm,garlaunch,garclip,"
                echo "                                  gartk,garchomp,gargears,gartop,garview,garcard"
                echo "                      Presets: all, desktop"
                echo "  --help              Show this help message"
                echo ""
                echo "Environment variables:"
                echo "  GAR_PREFIX          Installation prefix"
                echo "  GAR_BUILD_DIR       Build directory (default: ~/.local/src/gardesk)"
                echo ""
                echo "Examples:"
                echo "  $0                              # Interactive install"
                echo "  $0 --component=desktop          # Install desktop components"
                echo "  $0 --component=gar,garterm -y   # Non-interactive, specific components"
                echo ""
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
}

main() {
    parse_args "$@"

    show_banner

    # System detection
    local os
    local distro
    local arch

    os=$(detect_os)
    distro=$(detect_distro)
    arch=$(detect_arch)

    log_info "System: $distro ($os) on $arch"

    # Platform check
    if [ "$os" != "linux" ]; then
        log_error "gar Desktop Suite only supports Linux (X11)"
        log_error "Detected OS: $os"
        exit 1
    fi

    # Component selection (if not specified via CLI)
    if [ "$INSTALL_GAR" = false ] && [ "$INSTALL_GARFIELD" = false ] && \
       [ "$INSTALL_GARTERM" = false ] && [ "$INSTALL_GARBAR" = false ] && \
       [ "$INSTALL_GARTRAY" = false ] && [ "$INSTALL_GARNOTIFY" = false ] && \
       [ "$INSTALL_GARBG" = false ] && [ "$INSTALL_GARSHOT" = false ] && \
       [ "$INSTALL_GARLOCK" = false ] && [ "$INSTALL_GARDM" = false ] && \
       [ "$INSTALL_GARLAUNCH" = false ] && [ "$INSTALL_GARCLIP" = false ] && \
       [ "$INSTALL_GARTK" = false ] && [ "$INSTALL_GARCHOMP" = false ] && \
       [ "$INSTALL_GARGEARS" = false ] && [ "$INSTALL_GARTOP" = false ] && \
       [ "$INSTALL_GARVIEW" = false ] && [ "$INSTALL_GARCARD" = false ]; then
        prompt_components
    fi

    show_selection_summary

    # Confirmation
    if ! prompt_yes_no "Proceed with installation?"; then
        log_info "Installation cancelled"
        exit 0
    fi

    # Dependencies
    if [ "$SKIP_DEPS" = false ]; then
        echo ""
        if prompt_yes_no "Install build dependencies? (requires sudo)"; then
            install_dependencies "$distro"
        fi
    fi

    # Rust
    ensure_rust

    # Fetch source
    fetch_source

    # Install components
    echo ""
    log_step "Installing components..."
    echo ""

    # Build gartk first if needed (it's a dependency for other components)
    [ "$INSTALL_GARTK" = true ] && install_gartk

    # Core components
    [ "$INSTALL_GAR" = true ] && install_gar
    [ "$INSTALL_GARFIELD" = true ] && install_garfield
    [ "$INSTALL_GARTERM" = true ] && install_garterm
    [ "$INSTALL_GARBAR" = true ] && install_garbar
    [ "$INSTALL_GARTRAY" = true ] && install_gartray
    [ "$INSTALL_GARNOTIFY" = true ] && install_garnotify
    [ "$INSTALL_GARBG" = true ] && install_garbg
    [ "$INSTALL_GARSHOT" = true ] && install_garshot
    [ "$INSTALL_GARLOCK" = true ] && install_garlock
    [ "$INSTALL_GARLAUNCH" = true ] && install_garlaunch
    [ "$INSTALL_GARCLIP" = true ] && install_garclip
    [ "$INSTALL_GARCHOMP" = true ] && install_garchomp
    [ "$INSTALL_GARGEARS" = true ] && install_gargears
    [ "$INSTALL_GARTOP" = true ] && install_gartop
    [ "$INSTALL_GARVIEW" = true ] && install_garview
    [ "$INSTALL_GARCARD" = true ] && install_garcard

    # gardm last (may prompt for reboot)
    [ "$INSTALL_GARDM" = true ] && install_gardm

    # PATH setup
    setup_path

    # Success!
    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                                  ║${NC}"
    echo -e "${GREEN}║   ${BOLD}Installation complete!${NC}${GREEN}                                       ║${NC}"
    echo -e "${GREEN}║                                                                  ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    log_info "Binaries installed to: $BIN_DIR"
    log_info "Session files at: $SHARE_DIR"
    log_info "Source code at: $BUILD_DIR"
    echo ""

    echo -e "${BOLD}Next steps:${NC}"
    echo ""
    echo "  1. Log out and select 'gar' from your display manager"
    echo "     Or start from TTY: startx $SHARE_DIR/gar-session.sh"
    echo ""
    echo "  2. Edit your configuration:"
    echo "     ~/.config/gar/init.lua"
    echo ""

    if [ "$INSTALL_GARTERM" = true ]; then
        echo "  Set garterm as default terminal in ~/.config/gar/init.lua:"
        echo "     gar.terminal = { cmd = \"garterm\" }"
        echo "  Bind: gar.key({ gar.mod, \"Return\", gar.spawn(\"garterm\") })"
        echo ""
    fi

    if [ "$INSTALL_GARFIELD" = true ]; then
        echo "  Bind garfield file manager in ~/.config/gar/init.lua:"
        echo "     gar.key({ gar.mod, \"e\", gar.spawn(\"garfield\") })"
        echo ""
    fi

    if [ "$INSTALL_GARBG" = true ]; then
        echo "  Enable wallpaper daemon:"
        echo "     systemctl --user enable --now garbg"
        echo ""
    fi

    if [ "$INSTALL_GARSHOT" = true ]; then
        echo "  Screenshot keybinds (add to ~/.config/gar/init.lua):"
        echo "     Ctrl+Shift+4: garshot select  (region with blur overlay)"
        echo "     Ctrl+Shift+5: garshot screen  (full screen)"
        echo "     Ctrl+Shift+6: garshot window  (active window)"
        echo ""
    fi

    if [ "$INSTALL_GARLAUNCH" = true ]; then
        echo "  Bind garlaunch to a key in ~/.config/gar/init.lua:"
        echo "     gar.key({ gar.mod, \"d\", gar.spawn(\"garlaunch\") })"
        echo ""
    fi

    if [ "$INSTALL_GARCLIP" = true ]; then
        echo "  Enable clipboard manager:"
        echo "     systemctl --user enable --now garclip"
        echo ""
        echo "  Bind garclip-picker to a key in ~/.config/gar/init.lua:"
        echo "     gar.key({ gar.mod, \"v\", gar.spawn(\"garclip-picker\") })"
        echo ""
    fi

    if [ "$INSTALL_GARTRAY" = true ]; then
        echo "  gartray integrates with garbar's tray module"
        echo "  Control via: gartrayctl toggle-panel"
        echo ""
    fi

    if [ "$INSTALL_GARNOTIFY" = true ]; then
        echo "  garnotify auto-starts with gar when gar.notification is configured:"
        echo "     gar.notification = { position = \"top_right\" }"
        echo "  Control via: garnotifyctl pause|resume|history"
        echo ""
    fi

    if [ "$INSTALL_GARCHOMP" = true ]; then
        echo "  garchomp compositor (alternative to picom):"
        echo "     Enable with: systemctl --user enable --now garchomp"
        echo "     Or set: gar.set(\"compositor\", \"garchomp\") in init.lua"
        echo "  Control via: garchompctl enable|disable|blur|status"
        echo ""
    fi

    if [ "$INSTALL_GARGEARS" = true ]; then
        echo "  gargears configuration GUI:"
        echo "     Launch with: gargears"
        echo "     Or run as daemon for tray integration: gargears --daemon"
        echo ""
    fi

    if [ "$INSTALL_GARVIEW" = true ]; then
        echo "  garview image & document viewer:"
        echo "     Open files: garview /path/to/file.pdf"
        echo "     Control via: garviewctl open|next|prev|zoom-in|info"
        echo "     Annotations: Ctrl+A to enter annotation mode"
        echo ""
    fi

    if [ "$INSTALL_GARTOP" = true ]; then
        echo "  gartop system monitor:"
        echo "     Launch GUI with: gartop"
        echo "     Enable daemon: systemctl --user enable --now gartop"
        echo "     Query metrics: gartopctl cpu|memory|network|processes"
        echo ""
    fi

    if [ "$INSTALL_GARCARD" = true ]; then
        echo "  garcard authentication agent:"
        echo "     Enable daemon: systemctl --user enable --now garcard"
        echo "     Query status: garcardctl status"
        echo "     Inspect diagnostics: garcardctl diagnose"
        echo "     Check sessions: garcardctl auth-summary"
        echo "     Manage temp auth: garcardctl temp-list|temp-revoke-all"
        echo ""
    fi

    echo -e "${DIM}Documentation: https://gar.musicsian.com${NC}"
    echo ""
}

# Run main
main "$@"
