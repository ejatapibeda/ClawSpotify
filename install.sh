#!/bin/bash
set -euo pipefail

# ── Self-fix: hapus CRLF dari script ini sendiri ─────────────────────────────
if grep -qP '\r$' "${BASH_SOURCE[0]}" 2>/dev/null; then
    sed -i 's/\r$//' "${BASH_SOURCE[0]}"
    exec bash "${BASH_SOURCE[0]}" "$@"
fi

# ── ClawSpotify installer ─────────────────────────────────────────────────────
# Creates a CLI wrapper (spotify-ctl) and optionally links as an OpenClaw skill.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_PATH="${SCRIPT_DIR}/scripts/spotify.py"
BIN_DIR="${HOME}/.local/bin"
BIN_NAME="spotify-ctl"
SKILL_DIR="${HOME}/.openclaw/workspace/skills"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# ── 0. Fix line endings pada semua file proyek ────────────────────────────────

fix_line_endings() {
    local file="$1"
    if [ -f "$file" ]; then
        sed -i 's/\r$//' "$file"
    fi
}

# Fix script Python utama
fix_line_endings "$SCRIPT_PATH"

# Fix wrapper lama kalau ada
if [ -f "$BIN_DIR/$BIN_NAME" ]; then
    fix_line_endings "$BIN_DIR/$BIN_NAME"
fi

# Fix semua file .py dan .sh di direktori proyek
find "$SCRIPT_DIR" -type f \( -name "*.py" -o -name "*.sh" \) -exec sed -i 's/\r$//' {} +

# ── 1. Check Python 3 ─────────────────────────────────────────────────────────

if ! command -v python3 &>/dev/null; then
    echo -e "${RED}✗ Error: python3 is required but not found.${NC}"
    echo "  Install Python 3 from https://python.org and try again."
    exit 1
fi

PYTHON_VER="$(python3 --version 2>&1)"
echo -e "${GREEN}✓${NC} Found: ${PYTHON_VER}"

# ── 2. Check / install spotapi ───────────────────────────────────────────────

SPOTAPI_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/SpotAPI"

_try_import_spotapi() {
    python3 -c "import spotapi" 2>/dev/null
}

_import_error_spotapi() {
    python3 -c "import spotapi" 2>&1 | head -5
}

if ! _try_import_spotapi; then
    echo ""
    echo -e "${YELLOW}⚠  spotapi is not importable (may be broken PyPI build for this arch).${NC}"
    echo "   Attempting to install from local source: ${SPOTAPI_SRC}"
    echo ""

    if [ ! -f "${SPOTAPI_SRC}/setup.py" ]; then
        echo -e "${RED}✗ Error: SpotAPI source not found at: ${SPOTAPI_SRC}${NC}"
        echo "   Clone the repo alongside ClawSpotify, or install manually:"
        echo -e "   ${CYAN}pip install spotapi${NC}"
        exit 1
    fi

    # Uninstall broken PyPI build first, then install from source
    python3 -m pip uninstall -y spotapi 2>/dev/null || true
    if python3 -m pip install -e "${SPOTAPI_SRC}" --quiet; then
        if _try_import_spotapi; then
            echo -e "${GREEN}✓${NC} spotapi installed from local source."
        else
            echo -e "${RED}✗ Error: spotapi still fails to import after local install.${NC}"
            echo "  Details:"
            _import_error_spotapi | sed 's/^/    /'
            echo ""
            echo "  This is likely a missing native dependency (e.g. tls_client has no ARM build)."
            echo "  Try: pip install tls-client --upgrade"
            exit 1
        fi
    else
        echo -e "${RED}✗ Error: pip install from source failed.${NC}"
        echo "  Try manually: pip install -e ${SPOTAPI_SRC}"
        exit 1
    fi
fi

SPOTAPI_VER="$(python3 -c "import spotapi; print(getattr(spotapi, '__version__', 'installed'))" 2>/dev/null || echo "installed")"
echo -e "${GREEN}✓${NC} Found: spotapi (${SPOTAPI_VER})"

# ── 3. Ensure script is executable ───────────────────────────────────────────

chmod +x "$SCRIPT_PATH"

# ── 4. Create CLI wrapper ─────────────────────────────────────────────────────

mkdir -p "$BIN_DIR"

# Tulis wrapper dengan printf supaya pasti LF, bukan CRLF
printf '#!/bin/bash\nexec python3 "%s" "$@"\n' "$SCRIPT_PATH" > "$BIN_DIR/$BIN_NAME"
chmod +x "$BIN_DIR/$BIN_NAME"

echo -e "${GREEN}✓${NC} CLI installed: ${BIN_DIR}/${BIN_NAME}"

# ── 5. PATH warning ───────────────────────────────────────────────────────────

if [[ ":${PATH}:" != *":${BIN_DIR}:"* ]]; then
    echo ""
    echo -e "${YELLOW}⚠  ${BIN_DIR} is not in your PATH.${NC}"
    echo "   Add this line to your shell profile (~/.bashrc, ~/.zshrc, etc.):"
    echo ""
    echo '     export PATH="${HOME}/.local/bin:${PATH}"'
    echo ""
    echo "   Then reload your shell:  source ~/.bashrc  (or restart terminal)"
fi

# ── 6. Link as OpenClaw skill (optional) ─────────────────────────────────────

if [ -d "${HOME}/.openclaw" ]; then
    echo ""
    read -r -p "Link as OpenClaw workspace skill? [Y/n] " response
    response="${response:-Y}"
    if [[ "${response}" =~ ^[Yy]$ ]]; then
        mkdir -p "$SKILL_DIR"
        LINK_TARGET="$SKILL_DIR/spotify"
        if [ -L "$LINK_TARGET" ] || [ -d "$LINK_TARGET" ]; then
            rm -rf "$LINK_TARGET"
        fi
        ln -s "$SCRIPT_DIR" "$LINK_TARGET"
        echo -e "${GREEN}✓${NC} Skill linked: ${LINK_TARGET} → ${SCRIPT_DIR}"
        echo ""
        echo "  Restart the daemon to pick up the new skill:"
        echo "    openclaw daemon restart"
    fi
fi

# ── 7. First-time setup reminder ──────────────────────────────────────────────

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  Next steps                                                  ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║                                                              ║"
echo "║  1. Get your Spotify cookies (one-time):                     ║"
echo "║     • Open https://open.spotify.com and log in               ║"
echo "║     • Press F12 → Application → Cookies → open.spotify.com  ║"
echo "║     • Copy sp_dc and sp_key values                          ║"
echo "║                                                              ║"
echo "║  2. Save your session:                                       ║"
echo '║     spotify-ctl setup --sp-dc "..." --sp-key "..."          ║'
echo "║                                                              ║"
echo "║  3. Start playing!                                           ║"
echo '║     spotify-ctl status                                       ║'
echo '║     spotify-ctl play "your song"                             ║'
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# ── 8. Verify ─────────────────────────────────────────────────────────────────

if command -v "$BIN_NAME" &>/dev/null; then
    echo -e "${GREEN}✓${NC} Ready! Try: ${BIN_NAME} status"
else
    echo -e "${GREEN}✓${NC} Installed. After updating PATH, try: ${BIN_NAME} status"
fi
