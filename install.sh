#!/bin/bash
# ClawSpotify installer
# Usage: bash install.sh
# Installs the `clawspotify` command to ~/.local/bin

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"
TARGET="$BIN_DIR/clawspotify"
OLD_TARGET="$BIN_DIR/spotify-ctl"

echo "=== ClawSpotify Installer ==="

# Remove old symlink/binary if exists
if [ -L "$OLD_TARGET" ] || [ -f "$OLD_TARGET" ]; then
    echo "  Removing old 'spotify-ctl' from $OLD_TARGET"
    rm -f "$OLD_TARGET"
fi

# Create ~/.local/bin if not exists
mkdir -p "$BIN_DIR"

# Remove old clawspotify symlink if exists
rm -f "$TARGET"

# Create new symlink
ln -s "$SCRIPT_DIR/clawspotify" "$TARGET"
chmod +x "$SCRIPT_DIR/clawspotify"

echo "  Installed: clawspotify -> $TARGET"

# Check PATH
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo ""
    echo "  ⚠ '$BIN_DIR' is not in your PATH."
    echo "    Add this to your ~/.bashrc or ~/.zshrc:"
    echo "    export PATH=\"\${HOME}/.local/bin:\${PATH}\""
    echo "    Then run: source ~/.bashrc"
else
    echo ""
    echo "  ✓ Done! Run: clawspotify --help"
fi
