#!/bin/bash
# gar Desktop Suite Uninstaller
# Removes all installed gar components

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

PREFIX="${GAR_PREFIX:-/usr/local}"
BIN_DIR="$PREFIX/bin"
SHARE_DIR="$PREFIX/share/gar"

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_step() { echo -e "${CYAN}==>${NC} ${BOLD}$1${NC}"; }

# Binaries to remove
BINARIES=(
    gar garctl
    garfield garfieldctl
    garterm gartermctl
    garbar garbarctl
    gartray gartrayctl
    garnotify garnotifyctl
    garbg
    garshot garshotctl
    garlock
    garlaunch garlaunchctl
    garclip garclipctl garclip-picker
    garchomp garchompctl
    gargears gargearsctl
)

# System binaries (gardm)
SYSTEM_BINARIES=(
    gardmd
    gardm-greeter
)

# User systemd services
USER_SERVICES=(
    garbg.service
    garclip.service
    garchomp.service
)

# User config directories (optional removal)
CONFIG_DIRS=(
    ~/.config/gar
    ~/.config/garfield
    ~/.config/garterm
    ~/.config/garbar
    ~/.config/gartray
    ~/.config/garnotify
    ~/.config/garbg
    ~/.config/garshot
    ~/.config/garlock
    ~/.config/garlaunch
    ~/.config/garclip
    ~/.config/garchomp
    ~/.config/gargears
)

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║           gar Desktop Suite Uninstaller                          ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Stop user services
log_step "Stopping user services..."
for service in "${USER_SERVICES[@]}"; do
    if systemctl --user is-active "$service" &>/dev/null; then
        log_info "Stopping $service..."
        systemctl --user stop "$service" 2>/dev/null || true
    fi
    if systemctl --user is-enabled "$service" &>/dev/null; then
        log_info "Disabling $service..."
        systemctl --user disable "$service" 2>/dev/null || true
    fi
done

# Remove user systemd service files
log_step "Removing user systemd services..."
for service in "${USER_SERVICES[@]}"; do
    if [ -f "$HOME/.config/systemd/user/$service" ]; then
        log_info "Removing $service..."
        rm -f "$HOME/.config/systemd/user/$service"
    fi
done
systemctl --user daemon-reload 2>/dev/null || true

# Remove binaries from /usr/local/bin
log_step "Removing binaries from $BIN_DIR..."
for bin in "${BINARIES[@]}"; do
    if [ -f "$BIN_DIR/$bin" ]; then
        log_info "Removing $bin..."
        sudo rm -f "$BIN_DIR/$bin"
    fi
done

# Remove system binaries (gardm)
log_step "Removing system binaries..."
for bin in "${SYSTEM_BINARIES[@]}"; do
    if [ -f "/usr/bin/$bin" ]; then
        log_info "Removing $bin..."
        sudo rm -f "/usr/bin/$bin"
    fi
done

# Remove share directory
if [ -d "$SHARE_DIR" ]; then
    log_step "Removing $SHARE_DIR..."
    sudo rm -rf "$SHARE_DIR"
fi

# Remove XSession entry
if [ -f /usr/share/xsessions/gar.desktop ]; then
    log_step "Removing XSession entry..."
    sudo rm -f /usr/share/xsessions/gar.desktop
fi

# Remove gardm system files
if [ -d /etc/gardm ]; then
    log_step "Removing gardm config..."
    sudo rm -rf /etc/gardm
fi

if [ -f /usr/lib/systemd/system/gardm.service ]; then
    log_step "Removing gardm systemd service..."
    sudo systemctl disable gardm 2>/dev/null || true
    sudo rm -f /usr/lib/systemd/system/gardm.service
    sudo systemctl daemon-reload
fi

# Optional: Remove PAM configs
if [ -f /etc/pam.d/garlock ]; then
    log_info "Removing /etc/pam.d/garlock..."
    sudo rm -f /etc/pam.d/garlock
fi
if [ -f /etc/pam.d/gardm ]; then
    log_info "Removing /etc/pam.d/gardm..."
    sudo rm -f /etc/pam.d/gardm
fi

# Ask about config directories
echo ""
echo -e "${YELLOW}The following user config directories exist:${NC}"
for dir in "${CONFIG_DIRS[@]}"; do
    expanded_dir="${dir/#\~/$HOME}"
    if [ -d "$expanded_dir" ]; then
        echo "  $dir"
    fi
done
echo ""
read -p "Remove user config directories? [y/N]: " remove_configs
if [[ "${remove_configs,,}" == "y" ]]; then
    log_step "Removing user config directories..."
    for dir in "${CONFIG_DIRS[@]}"; do
        expanded_dir="${dir/#\~/$HOME}"
        if [ -d "$expanded_dir" ]; then
            log_info "Removing $dir..."
            rm -rf "$expanded_dir"
        fi
    done
fi

# Optional: Remove build directory
BUILD_DIR="${GAR_BUILD_DIR:-$HOME/.local/src/gardesk}"
if [ -d "$BUILD_DIR" ]; then
    echo ""
    read -p "Remove build directory ($BUILD_DIR)? [y/N]: " remove_build
    if [[ "${remove_build,,}" == "y" ]]; then
        log_step "Removing build directory..."
        rm -rf "$BUILD_DIR"
    fi
fi

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✅ Uninstallation complete!                                     ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════╝${NC}"
echo ""
log_info "All gar components have been removed."
echo ""
