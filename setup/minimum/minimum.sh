#!/usr/bin/env bash
set -euo pipefail

# ─── Helpers ──────────────────────────────────────────────────────────────────

RED='\033[0;31m'; YELLOW='\033[1;33m'; GREEN='\033[0;32m'; NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

ask() {
    # ask <prompt> — returns 0 (yes) or 1 (no)
    local prompt="$1"
    while true; do
        read -r -p "$(echo -e "${YELLOW}?${NC} ${prompt} [y/N] ")" answer
        case "${answer,,}" in
            y|yes) return 0 ;;
            n|no|"") return 1 ;;
            *) echo "Please answer y or n." ;;
        esac
    done
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
    source /etc/os-release
    if [[ "${ID_LIKE:-}" != *debian* ]] && [[ "${ID}" != "debian" ]] && [[ "${ID}" != "ubuntu" ]]; then
        error "Unsupported OS: ${PRETTY_NAME:-${ID}}. Only Debian-like systems are supported."
        exit 1
    fi
    info "Detected OS: ${PRETTY_NAME:-${ID}}"
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

DOCKER_INSTALLED=false

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

# ─── User creation ────────────────────────────────────────────────────────────

create_user() {
    ask "Create a new system user?" || return 0

    # Username
    read -r -p "$(echo -e "${YELLOW}?${NC} Username [anonymous]: ")" NEW_USER
    NEW_USER="${NEW_USER:-anonymous}"

    # UID
    read -r -p "$(echo -e "${YELLOW}?${NC} UID [1027]: ")" NEW_UID
    NEW_UID="${NEW_UID:-1027}"

    if id "${NEW_USER}" &>/dev/null; then
        warn "User '${NEW_USER}' already exists — skipping useradd."
    else
        # Prefer 'wheel' group if it exists, otherwise fall back to 'sudo'
        local sudo_group
        sudo_group=$(getent group wheel &>/dev/null && echo wheel || echo sudo)

        info "Creating user '${NEW_USER}' (uid=${NEW_UID}, shell=fish, group=${sudo_group})…"
        useradd -m \
            -u "${NEW_UID}" \
            -s /bin/fish \
            -G "${sudo_group}" \
            "${NEW_USER}"
    fi

    # Passwordless sudo
    if ask "Grant '${NEW_USER}' passwordless sudo?"; then
        local sudoers_file="/etc/sudoers.d/${NEW_USER}"
        echo "${NEW_USER} ALL=(ALL) NOPASSWD: ALL" > "${sudoers_file}"
        chmod 0440 "${sudoers_file}"
        info "Sudoers entry written to ${sudoers_file}"
    fi

    # Docker group — only if Docker was installed in this run or is already present
    if getent group docker &>/dev/null; then
        if ask "Add '${NEW_USER}' to the 'docker' group?"; then
            usermod -aG docker "${NEW_USER}"
            info "Added '${NEW_USER}' to docker group."
        fi
    elif [[ "${DOCKER_INSTALLED}" == true ]]; then
        warn "Docker group not found even though Docker was just installed — skipping usermod."
    else
        info "Docker group not present; skipping docker group assignment."
    fi
}

# ─── SSH config ───────────────────────────────────────────────────────────────

configure_sshd() {
    ask "Write custom sshd config to /etc/ssh/sshd_config.d/custom.conf?" || return 0

    local conf_dir="/etc/ssh/sshd_config.d"
    local conf_file="${conf_dir}/custom.conf"
    mkdir -p "${conf_dir}"

    # Prompt for SSH port
    read -r -p "$(echo -e "${YELLOW}?${NC} SSH port [2222]: ")" SSH_PORT
    SSH_PORT="${SSH_PORT:-2222}"

    # Prompt for the user that is allowed password login
    read -r -p "$(echo -e "${YELLOW}?${NC} User allowed password login [anonymous]: ")" PASSWD_USER
    PASSWD_USER="${PASSWD_USER:-anonymous}"

    cat > "${conf_file}" <<EOF
# Custom SSHD configuration — generated by setup.sh
# Use SSH on None Standar Port
# Default:
#Port 22
Port ${SSH_PORT}

# Relocate HostKeys
# Default:
#HostKey /etc/ssh/ssh_host_rsa_key
#HostKey /etc/ssh/ssh_host_ecdsa_key
#HostKey /etc/ssh/ssh_host_ed25519_key

# Authentication:
# Permit Root Login
# Default:
#PermitRootLogin prohibit-password

# Expect .ssh/authorized_keys2 to be disregarded by default in future.
# Default:
#AuthorizedKeysFile     .ssh/authorized_keys .ssh/authorized_keys2

# To disable tunneled clear text passwords, change to no here!
# Default:
#PasswordAuthentication yes

# Authentication
PermitRootLogin prohibit-password
PasswordAuthentication no
PermitEmptyPasswords no

# Allow password login only for the specified user
Match User ${PASSWD_USER}
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

# ─── Dotfile symlinks ─────────────────────────────────────────────────────────

setup_dotlinks() {
    ask "Create dotfile symlinks under ~/.config?" || return 0

    # Determine target home directory
    local target_home="${HOME}"
    if [[ $EUID -eq 0 ]] && [[ -n "${SUDO_USER:-}" ]]; then
        target_home=$(getent passwd "${SUDO_USER}" | cut -d: -f6)
    fi

    local dotfiles="${target_home}/.dotfiles"
    if [[ ! -d "${dotfiles}" ]]; then
        warn "Dotfiles directory not found at ${dotfiles} — skipping symlinks."
        return 0
    fi

    local config_dir="${target_home}/.config"
    mkdir -p "${config_dir}"

    for target in nvim starship omf git; do
        local src="${dotfiles}/config/${target}"
        local dst="${config_dir}/${target}"
        if [[ -e "${src}" ]]; then
            if [[ -e "${dst}" ]] && [[ ! -L "${dst}" ]]; then
                warn "${dst} already exists and is not a symlink — skipping."
            else
                ln -sfn "${src}" "${dst}"
                info "Linked ${dst} -> ${src}"
            fi
        else
            warn "Source ${src} not found — skipping."
        fi
    done

    # ~/.bin — user scripts
    local bin_src="${dotfiles}/bin"
    local bin_dst="${target_home}/.bin"
    if [[ -e "${bin_src}" ]]; then
        if [[ -e "${bin_dst}" ]] && [[ ! -L "${bin_dst}" ]]; then
            warn "${bin_dst} exists and is not a symlink — skipping bin link."
        else
            ln -sfn "${bin_src}" "${bin_dst}"
            info "Linked ${bin_dst} -> ${bin_src}"
        fi
    else
        warn "bin source not found at ${bin_src} — skipping."
    fi

    # /etc/motd — system-wide message of the day
    local motd_src="${dotfiles}/setup/motd/motd"
    local motd_dst="/etc/motd"
    if [[ -e "${motd_src}" ]]; then
        if [[ -e "${motd_dst}" ]] && [[ ! -L "${motd_dst}" ]]; then
            warn "${motd_dst} exists and is not a symlink — skipping motd link."
        else
            ln -sfn "${motd_src}" "${motd_dst}"
            info "Linked ${motd_dst} -> ${motd_src}"
        fi
    else
        warn "motd source not found at ${motd_src} — skipping."
    fi
}

# ─── Oh My Fish ───────────────────────────────────────────────────────────────

install_omf() {
    ask "Install Oh My Fish?" || return 0

    local tmp_install
    tmp_install=$(mktemp)
    curl -fsSL https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install -o "${tmp_install}"
    fish "${tmp_install}" --path=~/.local/share/omf --config=~/.config/omf --noninteractive
    rm -f "${tmp_install}"
    info "Oh My Fish installed."
}

# ─── Main ─────────────────────────────────────────────────────────────────────

main() {
    must_be_root
    check_os

    echo
    info "=== Debian system setup ==="
    echo

    install_packages
    install_docker
    install_mise
    install_neovim
    create_user
    configure_sshd
    setup_dotlinks
    install_omf

    echo
    info "=== Setup complete ==="
}

main "$@"
