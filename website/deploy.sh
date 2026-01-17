#!/usr/bin/env bash
set -euo pipefail

# Configuration
SITE_NAME="gar.musicsian.com"
SITE_DIR="/var/www/$SITE_NAME"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

STAMP=$(date +%Y-%m-%d-%H%M%S)

echo "═══════════════════════════════════════════"
echo "  Deploying $SITE_NAME"
echo "  Timestamp: $STAMP"
echo "═══════════════════════════════════════════"

# Ensure we're in the website directory
cd "$SCRIPT_DIR"

echo ""
echo "▶ Installing dependencies"
npm ci

echo ""
echo "▶ Building site"
npm run build

echo ""
echo "▶ Creating release directory"
sudo mkdir -p "$SITE_DIR/releases/$STAMP"

echo ""
echo "▶ Copying build to release"
sudo rsync -az --delete dist/ "$SITE_DIR/releases/$STAMP/"

echo ""
echo "▶ Flipping symlink to new release"
sudo ln -nfs "$SITE_DIR/releases/$STAMP" "$SITE_DIR/current"

echo ""
echo "▶ Reloading nginx"
sudo systemctl reload nginx

echo ""
echo "▶ Cleaning old releases (keeping last 5)"
cd "$SITE_DIR/releases"
ls -1t | tail -n +6 | xargs -r sudo rm -rf

echo ""
echo "═══════════════════════════════════════════"
echo "  ✓ Deployed $STAMP"
echo "  https://$SITE_NAME"
echo "═══════════════════════════════════════════"
