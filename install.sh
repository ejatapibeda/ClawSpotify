#!/bin/bash
set -euo pipefail

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

# Convert this script and the Python script to UNIX line endings (fix Windows CRLF issues)
_fix_crlf() {
    if command -v dos2unix &>/dev/null; then
        dos2unix "$1" 2>/dev/null || true
    else
        sed -i 's/\r$//' "$1"
    fi
}

_fix_crlf "${BASH_SOURCE[0]}"
_fix_crlf "$SCRIPT_PATH"

# ── 1. Check Python 3 ─────────────────────────────────────────────────────────

if ! command -v python3 &>/dev/null; then
    echo -e "${RED}✗ Error: python3 is required but not found.${NC}"
    echo "  Install Python 3 from https://python.org and try again."
    exit 1
fi

PYTHON_VER="$(python3 --version 2>&1)"
echo -e "${GREEN}✓${NC} Found: ${PYTHON_VER}"

# ── 2. Check spotapi ──────────────────────────────────────────────────────────

# Detect spotapi: try plain python3 first, then search pipx venvs
SPOTAPI_PYTHONPATH=""

if python3 -c "import spotapi" &>/dev/null; then
    : # already visible to system python3
else
    # Try to find spotapi inside a pipx venv
    PIPX_HOME="${PIPX_HOME:-${HOME}/.local/pipx}"
    PIPX_LOCAL_VENVS="${PIPX_LOCAL_VENVS:-${PIPX_HOME}/venvs}"

    # Look for spotapi package in any pipx venv's site-packages
    FOUND_PATH=""
    for venv_dir in "$PIPX_LOCAL_VENVS"/*/lib/python*/site-packages; do
        if [ -d "${venv_dir}/spotapi" ]; then
            FOUND_PATH="$venv_dir"
            break
        fi
    done

    if [ -n "$FOUND_PATH" ]; then
        SPOTAPI_PYTHONPATH="$FOUND_PATH"
        if ! PYTHONPATH="$SPOTAPI_PYTHONPATH" python3 -c "import spotapi" &>/dev/null; then
            echo -e "${RED}✗ Error: Found spotapi at ${FOUND_PATH} but could not import it.${NC}"
            exit 1
        fi
    else
        echo ""
        echo -e "${RED}✗ Error: spotapi is not installed.${NC}"
        echo ""
        echo "  Install it with one of:"
        echo -e "    ${CYAN}pip install spotapi${NC}"
        echo -e "    ${CYAN}pip install -e ./SpotAPI${NC}   (if cloned from source)"
        echo -e "    ${CYAN}pipx install git+https://github.com/ejatapibeda/SpotAPI.git${NC}"
        echo ""
        exit 1
    fi
fi

SPOTAPI_VER="$(PYTHONPATH="${SPOTAPI_PYTHONPATH}" python3 -c "import spotapi; print(getattr(spotapi, '__version__', 'installed'))" 2>/dev/null || echo "installed")"
echo -e "${GREEN}✓${NC} Found: spotapi (${SPOTAPI_VER})"
if [ -n "$SPOTAPI_PYTHONPATH" ]; then
    echo -e "  ${CYAN}(via pipx venv: ${SPOTAPI_PYTHONPATH})${NC}"
fi

# ── 3. Ensure script is executable ───────────────────────────────────────────

chmod +x "$SCRIPT_PATH"

# ── 4. Create CLI wrapper ─────────────────────────────────────────────────────

mkdir -p "$BIN_DIR"

# Use printf to avoid heredoc CRLF issues when install.sh has Windows line endings
printf '#!/bin/bash\nexport PYTHONPATH="%s${PYTHONPATH:+:${PYTHONPATH}}"\nexec python3 "%s" "$@"\n' \
    "${SPOTAPI_PYTHONPATH}" \
    "${SCRIPT_PATH}" \
    > "$BIN_DIR/$BIN_NAME"
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
