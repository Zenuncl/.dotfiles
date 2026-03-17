#!/usr/bin/env bash
# Install a Nerd Font from GitHub releases (latest version, no full repo clone)
# Usage: ./nerdfont.sh [FontName]   default: JetBrainsMono
#
# Font name must match a release asset on:
#   https://github.com/ryanoasis/nerd-fonts/releases/latest
# Examples: JetBrainsMono, SourceCodePro, FiraCode, Hack, Meslo
set -euo pipefail

RED='\033[0;31m'; YELLOW='\033[1;33m'; GREEN='\033[0;32m'; NC='\033[0m'
info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

FONT="${1:-JetBrainsMono}"
FONT_DIR="${HOME}/.local/share/fonts/NerdFonts/${FONT}"

# ─── Resolve latest release ───────────────────────────────────────────────────

info "Resolving latest Nerd Fonts release…"
LATEST="$(curl -fsSL https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest \
    | grep '"tag_name"' | head -1 | cut -d'"' -f4)"
info "Latest version: ${LATEST}"

# ─── Download ─────────────────────────────────────────────────────────────────

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

ASSET="${FONT}.tar.xz"
URL="https://github.com/ryanoasis/nerd-fonts/releases/download/${LATEST}/${ASSET}"

info "Downloading ${FONT} font…"
curl -fsSL --progress-bar "${URL}" -o "${TMP_DIR}/${ASSET}" \
    || { error "Failed to download ${URL}"; error "Check font name — must match a release asset exactly."; exit 1; }

# ─── Install ──────────────────────────────────────────────────────────────────

info "Installing to ${FONT_DIR}…"
mkdir -p "${FONT_DIR}"
tar -xf "${TMP_DIR}/${ASSET}" -C "${FONT_DIR}"

# Remove Windows-only variants to keep the font dir clean
find "${FONT_DIR}" -name "*Windows*" -delete 2>/dev/null || true

info "Refreshing font cache…"
if command -v fc-cache &>/dev/null; then
    fc-cache -f "${FONT_DIR}"
else
    warn "fc-cache not found — install fontconfig and run 'fc-cache -f' manually."
fi

info "Done. ${FONT} Nerd Font ${LATEST} installed."
