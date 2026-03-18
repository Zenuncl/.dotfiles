#!/usr/bin/env bash
# Firewall setup — native nftables + fail2ban
# Loads pre-configured .nft rule files from firewall/nftables/.
#
# Docker safety: Docker uses 'table ip filter' and 'table ip nat'.
# This script manages 'table inet filter' exclusively — a completely
# separate table. Docker chains are never touched.
set -euo pipefail

RED='\033[0;31m'; YELLOW='\033[1;33m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }
step()  { echo -e "\n${CYAN}──── $* ────${NC}"; }

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

must_be_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root (or via sudo)."
        exit 1
    fi
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NFT_RULES_DIR="${SCRIPT_DIR}/nftables"
FAIL2BAN_DIR="${SCRIPT_DIR}/fail2ban"
NFT_CONF="/etc/nftables.conf"

SKIP_FAIL2BAN=false

# ─── Step 1: Check nftables ───────────────────────────────────────────────────

check_nftables() {
    step "nftables"

    if ! command -v nft &>/dev/null; then
        warn "nftables (nft) is not installed."
        if ask "Install nftables now?"; then
            apt-get update -qq
            apt-get install -y nftables
        else
            error "nftables is required. Aborting."
            exit 1
        fi
    fi

    info "nftables: $(nft --version | head -1)"
}

# ─── Step 2: Check fail2ban ───────────────────────────────────────────────────

check_fail2ban() {
    step "fail2ban"

    if ! command -v fail2ban-client &>/dev/null; then
        warn "fail2ban is not installed."
        if ask "Install fail2ban now?"; then
            apt-get update -qq
            apt-get install -y fail2ban
        else
            warn "Skipping fail2ban setup."
            SKIP_FAIL2BAN=true
            return 0
        fi
    fi

    info "fail2ban: $(fail2ban-client --version | head -1)"
}

# ─── Step 3: Warn if Docker is running ───────────────────────────────────────

check_docker() {
    if command -v docker &>/dev/null && docker info &>/dev/null 2>&1; then
        warn "Docker is running."
        warn "This script manages 'table inet filter' only."
        warn "Docker's 'table ip filter' and 'table ip nat' will NOT be touched."
        echo
    fi
}

# ─── Step 4: Initialise our nftables table and chains ────────────────────────

init_table() {
    step "Initialising table inet filter"

    # 'add' is idempotent — safe to run even if table/chain already exists
    nft "add table inet filter"
    nft "add chain inet filter input  { type filter hook input  priority filter; policy drop; }"
    nft "add chain inet filter output { type filter hook output priority filter; policy accept; }"

    # Flush only our chains — Docker's 'table ip filter' chains are untouched
    if ask "Flush existing rules in 'table inet filter' before loading? (recommended on re-run)"; then
        nft "flush chain inet filter input"
        nft "flush chain inet filter output"
        info "Chains flushed."
    fi

    # Optional: named set for SSH allowlist (populated manually)
    nft "add set inet filter ssh_allow { type ipv4_addr; flags interval; comment \"SSH source allowlist\"; }" 2>/dev/null || true
}

# ─── Step 5: Load .nft rule files ────────────────────────────────────────────

load_rules() {
    step "Loading nft rule files"

    if [[ ! -d "${NFT_RULES_DIR}" ]]; then
        error "nft rules directory not found: ${NFT_RULES_DIR}"
        exit 1
    fi

    local rule_files
    mapfile -t rule_files < <(find "${NFT_RULES_DIR}" -name "*.nft" | sort)

    if [[ ${#rule_files[@]} -eq 0 ]]; then
        warn "No .nft files found in ${NFT_RULES_DIR} — skipping."
        return 0
    fi

    for rule_file in "${rule_files[@]}"; do
        local name
        name="$(basename "${rule_file}")"
        if ask "Apply rule file: ${name}?"; then
            info "Applying ${name}…"
            # Strip comment lines and blank lines, apply each rule via nft
            while IFS= read -r line; do
                [[ -z "${line}"           ]] && continue   # skip blank
                [[ "${line}" =~ ^[[:space:]]*# ]] && continue   # skip comments
                nft "${line}" || { error "Failed rule: ${line}"; return 1; }
            done < "${rule_file}"
            info "${name} applied."
        else
            info "Skipped ${name}."
        fi
    done
}

# ─── Step 6: Persist to /etc/nftables.conf ───────────────────────────────────

persist_rules() {
    step "Persisting rules"

    if ! ask "Save current 'table inet filter' ruleset to ${NFT_CONF}?"; then
        warn "Rules not persisted — they will be lost on reboot."
        return 0
    fi

    # Back up existing conf if it's not ours
    if [[ -f "${NFT_CONF}" ]]; then
        cp "${NFT_CONF}" "${NFT_CONF}.bak"
        info "Existing ${NFT_CONF} backed up to ${NFT_CONF}.bak"
    fi

    # Export ONLY our table (not Docker's ip filter / ip nat)
    {
        echo "#!/usr/sbin/nft -f"
        echo "# Generated by firewall.sh — $(date -u '+%Y-%m-%d %H:%M UTC')"
        echo "# Manages: table inet filter only. Docker tables are separate."
        echo
        nft list table inet filter
    } > "${NFT_CONF}"

    info "Saved to ${NFT_CONF}"

    systemctl enable nftables
    systemctl restart nftables
    info "nftables service enabled and restarted."
}

# ─── Step 7: Setup fail2ban ───────────────────────────────────────────────────

setup_fail2ban() {
    [[ "${SKIP_FAIL2BAN}" == true ]] && return 0

    step "fail2ban configuration"

    local src="${FAIL2BAN_DIR}/jail.local"
    local dst="/etc/fail2ban/jail.local"

    if [[ ! -f "${src}" ]]; then
        warn "jail.local not found at ${src} — skipping."
        return 0
    fi

    if ask "Deploy jail.local to ${dst}?"; then
        if [[ -f "${dst}" ]] && [[ ! -L "${dst}" ]]; then
            cp "${dst}" "${dst}.bak"
            info "Existing jail.local backed up to ${dst}.bak"
        fi
        ln -sfn "${src}" "${dst}"
        info "Linked ${dst} -> ${src}"

        # Ensure banaction uses nftables (not iptables)
        if ! grep -q "nftables" "${src}"; then
            if ask "Update fail2ban banaction to nftables-allports (recommended)?"; then
                sed -i 's/banaction\s*=\s*iptables.*/banaction = nftables-allports/' "${src}"
                info "banaction set to nftables-allports in jail.local"
            fi
        else
            info "jail.local already uses nftables banaction."
        fi
    fi

    if ask "Enable and restart fail2ban?"; then
        systemctl enable fail2ban
        systemctl restart fail2ban
        info "fail2ban enabled and restarted."
        sleep 1
        fail2ban-client status 2>/dev/null | head -8 || true
    fi
}

# ─── Main ─────────────────────────────────────────────────────────────────────

main() {
    must_be_root

    echo
    info "=== Firewall setup: nftables (native) + fail2ban ==="
    echo

    check_nftables
    check_fail2ban
    check_docker
    init_table
    load_rules
    persist_rules
    setup_fail2ban

    echo
    info "=== Firewall setup complete. Current ruleset: ==="
    nft list table inet filter 2>/dev/null || true
}

main "$@"
