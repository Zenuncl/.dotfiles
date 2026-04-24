#!/usr/bin/env bash
# Mail setup — install packages, create symlinks, prepare directories.
#   bash ~/.dotfiles/mail/setup.sh
set -euo pipefail

# ─── Helpers ──────────────────────────────────────────────────────────────────

RED='\033[0;31m'; YELLOW='\033[1;33m'; GREEN='\033[0;32m'; NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

ask() {
    local prompt="$1"
    while true; do
        read -r -p "$(echo -e "${YELLOW}?${NC} ${prompt} [y/N] ")" answer </dev/tty
        case "${answer,,}" in
            y|yes) return 0 ;;
            n|no|"") return 1 ;;
            *) echo "Please answer y or n." ;;
        esac
    done
}

# ─── Paths ────────────────────────────────────────────────────────────────────

DOTFILES_MAIL="${HOME}/.dotfiles/mail"
CONFIG_DIR="${HOME}/.config"
MAIL_DIR="${HOME}/.local/share/mail"
CACHE_DIR="${HOME}/.cache/mutt"
STATE_DIR="${HOME}/.local/state/msmtp"

# ─── Package install ─────────────────────────────────────────────────────────

install_packages() {
    # Required
    local pkgs=(neomutt isync notmuch msmtp lynx pandoc)
    # Optional (password manager, URL extraction, diff viewer)
    local opt_pkgs=(pass urlscan git-delta)

    if command -v apt-get &>/dev/null; then
        info "Detected Debian/Ubuntu — using apt"
        info "Packages: ${pkgs[*]} ${opt_pkgs[*]}"
        sudo apt-get update -qq
        sudo apt-get install -y "${pkgs[@]}" "${opt_pkgs[@]}"
    elif command -v nix-env &>/dev/null || command -v nix &>/dev/null; then
        info "Detected Nix — use nix profile or add to your flake/config:"
        echo
        echo "  nix profile:"
        echo "    nix profile install nixpkgs#{neomutt,isync,notmuch,msmtp,lynx,pass,urlscan,pandoc,delta,glow}"
        echo
        echo "  flake / home-manager:"
        echo "    home.packages = with pkgs; [ neomutt isync notmuch msmtp lynx pass urlscan pandoc delta glow ];"
        echo
        warn "Nix packages not installed automatically — add them yourself."
        return 0
    elif command -v pacman &>/dev/null; then
        info "Detected Arch — using pacman"
        info "Packages: ${pkgs[*]} ${opt_pkgs[*]}"
        sudo pacman -Sy --needed --noconfirm "${pkgs[@]}" "${opt_pkgs[@]}"
    else
        error "Unsupported package manager. Install manually:"
        echo "  neomutt isync notmuch msmtp lynx pass urlscan pandoc git-delta glow"
        return 1
    fi
    info "Packages installed."
}

# ─── Symlinks ─────────────────────────────────────────────────────────────────

link() {
    local src="$1" dst="$2"
    if [[ ! -e "${src}" ]]; then
        warn "Source not found: ${src} — skipping."
        return
    fi
    if [[ -e "${dst}" ]] && [[ ! -L "${dst}" ]]; then
        warn "${dst} exists and is not a symlink — skipping (back up manually if needed)."
        return
    fi
    ln -sfn "${src}" "${dst}"
    info "Linked ${dst} → ${src}"
}

setup_symlinks() {
    mkdir -p "${CONFIG_DIR}"

    link "${DOTFILES_MAIL}/mutt"    "${CONFIG_DIR}/mutt"
    link "${DOTFILES_MAIL}/isync"   "${CONFIG_DIR}/isync"
    link "${DOTFILES_MAIL}/msmtp"   "${CONFIG_DIR}/msmtp"
    link "${DOTFILES_MAIL}/notmuch" "${CONFIG_DIR}/notmuch"
    link "${DOTFILES_MAIL}/glow"    "${CONFIG_DIR}/glow"

    info "Symlinks created."
}

# ─── Directories ──────────────────────────────────────────────────────────────

setup_directories() {
    mkdir -p "${MAIL_DIR}"
    mkdir -p "${CACHE_DIR}"
    mkdir -p "${STATE_DIR}"

    info "Created ${MAIL_DIR}  (maildir root)"
    info "Created ${CACHE_DIR}  (neomutt cache)"
    info "Created ${STATE_DIR}  (msmtp logs)"
}

# ─── Main ─────────────────────────────────────────────────────────────────────

main() {
    echo
    info "=== Mail setup ==="
    echo

    if [[ ! -d "${DOTFILES_MAIL}" ]]; then
        error "Dotfiles mail directory not found at ${DOTFILES_MAIL}"
        exit 1
    fi

    # Phase 1 — packages
    if ask "Install packages (neomutt, isync, notmuch, msmtp, lynx, pass, urlscan)?"; then
        install_packages
    fi

    # Phase 2 — symlinks
    if ask "Create config symlinks (~/.config/{mutt,isync,msmtp,notmuch})?"; then
        setup_symlinks
    fi

    # Phase 3 — directories
    if ask "Create mail & cache directories?"; then
        setup_directories
    fi

    echo
    info "=== Setup complete ==="
    echo
    echo "Next steps:"
    echo
    echo "  Option A — gen.sh (recommended, single source of truth):"
    echo "    1. cp ~/.dotfiles/mail/accounts/example.conf ~/.dotfiles/mail/accounts/personal.conf"
    echo "    2. Edit personal.conf (5 lines for Gmail, 7 for generic IMAP)"
    echo "    3. pass insert email/gmail"
    echo "    4. bash ~/.dotfiles/mail/gen.sh"
    echo "    5. mbsync --config ~/.config/isync/mbsyncrc --all && notmuch new"
    echo "    6. neomutt"
    echo
    echo "  Option B — manual (edit example files directly):"
    echo "    1. cp ~/.config/isync/mbsyncrc.example   ~/.config/isync/mbsyncrc"
    echo "    2. cp ~/.config/msmtp/config.example      ~/.config/msmtp/config"
    echo "    3. cp ~/.config/mutt/accounts/example.muttrc ~/.config/mutt/accounts/personal.muttrc"
    echo "    4. Edit each file, then uncomment the source line in neomuttrc"
    echo
    echo "  notmuch uses XDG default: ~/.config/notmuch/default/config (no env var needed)"
}

main "$@"
