#!/usr/bin/env bash
# Bootstrap script — safe to pipe directly from GitHub:
#   curl -fsSL https://raw.githubusercontent.com/Zenuncl/.dotfiles/master/setup/bootstrap.sh | sudo bash
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

prompt() {
    # prompt <message> <default> — prints value to stdout
    local msg="$1" default="$2" value
    read -r -p "$(echo -e "${YELLOW}?${NC} ${msg} [${default}]: ")" value </dev/tty
    echo "${value:-${default}}"
}

must_be_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root (or via sudo)."
        exit 1
    fi
}

# ─── OS Check ─────────────────────────────────────────────────────────────────

check_os() {
    if [[ ! -f /etc/os-release ]]; then
        error "Cannot detect OS — /etc/os-release not found. Only Debian-like systems are supported."
        exit 1
    fi
    # shellcheck source=/dev/null
    source /etc/os-release
    if [[ "${ID_LIKE:-}" != *debian* ]] && [[ "${ID}" != "debian" ]] && [[ "${ID}" != "ubuntu" ]]; then
        error "Unsupported OS: ${PRETTY_NAME:-${ID}}. Only Debian-like systems are supported."
        exit 1
    fi
    info "Detected OS: ${PRETTY_NAME:-${ID}}"
}

# ─── Constants ────────────────────────────────────────────────────────────────

DOTFILES_REPO="https://github.com/Zenuncl/.dotfiles.git"
DOTFILES_DIR=".dotfiles"

DOCKER_INSTALLED=false

# ─── Step 1: Ensure user exists ───────────────────────────────────────────────

ensure_user() {
    TARGET_USER=$(prompt "Username to set up" "anonymous")
    TARGET_UID=$(prompt "UID" "1027")

    if id "${TARGET_USER}" &>/dev/null; then
        info "User '${TARGET_USER}' already exists."
        TARGET_HOME=$(getent passwd "${TARGET_USER}" | cut -d: -f6)
        return 0
    fi

    info "User '${TARGET_USER}' not found — creating…"

    local sudo_group
    sudo_group=$(getent group wheel &>/dev/null && echo wheel || echo sudo)

    useradd -m \
        -u "${TARGET_UID}" \
        -s /bin/fish \
        -G "${sudo_group}" \
        "${TARGET_USER}"

    TARGET_HOME=$(getent passwd "${TARGET_USER}" | cut -d: -f6)
    info "User '${TARGET_USER}' created (home: ${TARGET_HOME})."

    if ask "Grant '${TARGET_USER}' passwordless sudo?"; then
        local sudoers_file="/etc/sudoers.d/${TARGET_USER}"
        echo "${TARGET_USER} ALL=(ALL) NOPASSWD: ALL" > "${sudoers_file}"
        chmod 0440 "${sudoers_file}"
        info "Sudoers entry written to ${sudoers_file}"
    fi
}

# ─── Step 2: Ensure dotfiles are cloned ───────────────────────────────────────

ensure_dotfiles() {
    local dotfiles_path="${TARGET_HOME}/${DOTFILES_DIR}"

    if [[ -d "${dotfiles_path}/.git" ]]; then
        info "Dotfiles already cloned at ${dotfiles_path}."
        return 0
    fi

    if [[ -d "${dotfiles_path}" ]]; then
        warn "${dotfiles_path} exists but is not a git repo — removing and re-cloning."
        rm -rf "${dotfiles_path}"
    fi

    info "Cloning dotfiles from ${DOTFILES_REPO}…"
    git clone "${DOTFILES_REPO}" "${dotfiles_path}"
    chown -R "${TARGET_USER}:${TARGET_USER}" "${dotfiles_path}"
    info "Dotfiles cloned to ${dotfiles_path}."
}

# ─── APT packages ─────────────────────────────────────────────────────────────

install_packages() {
    ask "Update & upgrade APT packages and install base tools?" || return 0

    info "Running apt update / upgrade / dist-upgrade…"
    apt update
    apt -y upgrade
    apt -y dist-upgrade

    info "Installing base packages…"
    apt install -y \
        sudo git git-delta fish vim curl wget tmux fasd \
        ca-certificates gnupg net-tools sshpass cifs-utils unzip \
        lynx traceroute fail2ban iptables build-essential \
        openssh-server dnsutils qemu-utils bat starship whois \
        htop rsync rclone fzf
}

# ─── Docker ───────────────────────────────────────────────────────────────────

install_docker() {
    ask "Install Docker (via get.docker.com)?" || return 0

    info "Installing Docker…"
    curl -fsSL https://get.docker.com | sh
    DOCKER_INSTALLED=true
}

# ─── mise ─────────────────────────────────────────────────────────────────────

install_mise() {
    ask "Install mise (runtime version manager)?" || return 0

    info "Installing mise…"
    curl -fsSL https://mise.run | sh
}

# ─── Neovim ───────────────────────────────────────────────────────────────────

install_neovim() {
    ask "Install latest Neovim from GitHub releases?" || return 0

    local archive="nvim-linux-x86_64.tar.gz"
    info "Downloading Neovim…"
    curl -LO "https://github.com/neovim/neovim/releases/latest/download/${archive}"
    rm -rf /opt/nvim-linux-x86_64
    tar -C /opt -xzf "${archive}"
    rm -f "${archive}"
    info "Neovim installed to /opt/nvim-linux-x86_64"
}

# ─── SSH config ───────────────────────────────────────────────────────────────

configure_sshd() {
    ask "Write custom sshd config to /etc/ssh/sshd_config.d/custom.conf?" || return 0

    local conf_dir="/etc/ssh/sshd_config.d"
    local conf_file="${conf_dir}/custom.conf"
    mkdir -p "${conf_dir}"

    local ssh_port passwd_user
    ssh_port=$(prompt "SSH port" "2222")
    passwd_user=$(prompt "User allowed password login" "anonymous")

    cat > "${conf_file}" <<EOF
# Custom SSHD configuration — generated by bootstrap.sh

Port ${ssh_port}

# Authentication
PermitRootLogin prohibit-password
PasswordAuthentication no
PermitEmptyPasswords no

# Allow password login only for the specified user
Match User ${passwd_user}
    PasswordAuthentication yes
Match all

# Forwarding & misc
AllowAgentForwarding yes
AllowTcpForwarding yes
X11Forwarding yes
PrintMotd no
EOF

    info "SSHD config written to ${conf_file}"

    if ask "Restart sshd now?"; then
        systemctl restart sshd && info "sshd restarted." || warn "Failed to restart sshd."
    fi
}

# ─── Symlinks ─────────────────────────────────────────────────────────────────

setup_dotlinks() {
    ask "Create dotfile symlinks?" || return 0

    local dotfiles="${TARGET_HOME}/${DOTFILES_DIR}"
    local config_dir="${TARGET_HOME}/.config"
    mkdir -p "${config_dir}"

    _link() {
        local src="$1" dst="$2"
        if [[ ! -e "${src}" ]]; then
            warn "Source not found: ${src} — skipping."
            return
        fi
        if [[ -e "${dst}" ]] && [[ ! -L "${dst}" ]]; then
            warn "${dst} exists and is not a symlink — skipping."
            return
        fi
        ln -sfn "${src}" "${dst}"
        info "Linked ${dst} -> ${src}"
    }

    # ~/.config/* links
    for target in nvim starship omf git; do
        _link "${dotfiles}/config/${target}" "${config_dir}/${target}"
    done

    # ~/.bin
    _link "${dotfiles}/bin" "${TARGET_HOME}/.bin"

    # /etc/motd
    _link "${dotfiles}/setup/motd/motd" "/etc/motd"
}

# ─── Oh My Fish ───────────────────────────────────────────────────────────────

install_omf() {
    ask "Install Oh My Fish?" || return 0

    local tmp_install
    tmp_install=$(mktemp)
    chmod 644 "${tmp_install}"
    curl -fsSL https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install -o "${tmp_install}"
    sudo -u "${TARGET_USER}" fish "${tmp_install}" \
        --path="${TARGET_HOME}/.local/share/omf" \
        --config="${TARGET_HOME}/.config/omf" \
        --noninteractive
    rm -f "${tmp_install}"
    info "Oh My Fish installed."
}

# ─── Docker group (after docker is installed) ─────────────────────────────────

add_docker_group() {
    if ! getent group docker &>/dev/null; then
        info "Docker group not present — skipping."
        return 0
    fi
    if ask "Add '${TARGET_USER}' to the 'docker' group?"; then
        usermod -aG docker "${TARGET_USER}"
        info "Added '${TARGET_USER}' to docker group."
    fi
}

# ─── Main ─────────────────────────────────────────────────────────────────────

main() {
    must_be_root
    check_os

    echo
    info "=== Bootstrap: Debian system setup ==="
    echo

    # Phase 1 — identity & dotfiles (must happen first)
    ensure_user
    ensure_dotfiles

    # Phase 2 — system setup
    install_packages
    install_docker
    install_mise
    install_neovim
    configure_sshd
    setup_dotlinks
    install_omf

    # Phase 3 — docker group (after docker install)
    add_docker_group

    echo
    info "=== Bootstrap complete. Log in as '${TARGET_USER}' to start. ==="
}

main "$@"
