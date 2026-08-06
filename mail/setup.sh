#!/usr/bin/env bash
# Mail setup — install packages, create symlinks, prepare directories.
#   bash ~/.dotfiles/mail/setup.sh
set -euo pipefail

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

DOTFILES_MAIL="${HOME}/.dotfiles/mail"
CONFIG_DIR="${HOME}/.config"

install_packages() {
    local pkgs=(aerc lynx pandoc)
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
        echo "    nix profile install nixpkgs#{aerc,lynx,pass,urlscan,pandoc,delta}"
        echo
        echo "  flake / home-manager:"
        echo "    home.packages = with pkgs; [ aerc lynx pass urlscan pandoc delta ];"
        echo
        warn "Nix packages not installed automatically — add them yourself."
        return 0
    elif command -v pacman &>/dev/null; then
        info "Detected Arch — using pacman"
        info "Packages: ${pkgs[*]} ${opt_pkgs[*]}"
        sudo pacman -Sy --needed --noconfirm "${pkgs[@]}" "${opt_pkgs[@]}"
    else
        error "Unsupported package manager. Install manually:"
        echo "  aerc lynx pass urlscan pandoc git-delta"
        return 1
    fi
    info "Packages installed."
}

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

    link "${DOTFILES_MAIL}/aerc"    "${CONFIG_DIR}/aerc"

    info "Symlinks created."
}

main() {
    echo
    info "=== Mail setup ==="
    echo

    if [[ ! -d "${DOTFILES_MAIL}" ]]; then
        error "Dotfiles mail directory not found at ${DOTFILES_MAIL}"
        exit 1
    fi

    if ask "Install packages (aerc, lynx, pandoc, pass, urlscan, delta)?"; then
        install_packages
    fi

    if ask "Create config symlinks (~/.config/aerc)?"; then
        setup_symlinks
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
    echo "    5. aerc"
    echo
    echo "  Option B — manual (edit example files directly):"
    echo "    1. cp ~/.config/aerc/accounts.conf.example ~/.config/aerc/accounts.conf"
    echo "    2. Edit accounts.conf, then: chmod 600 ~/.config/aerc/accounts.conf"
    echo "    3. aerc"
}

main "$@"
