#!/usr/bin/env bash
# Reads accounts/*.conf and generates aerc/accounts.conf.
#   bash ~/.dotfiles/mail/gen.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ACCOUNTS_DIR="${SCRIPT_DIR}/accounts"
AERC_DIR="${SCRIPT_DIR}/aerc"

GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'
info() { echo -e "${GREEN}✓${NC} $*"; }
die()  { echo -e "${RED}✗${NC} $*" >&2; exit 1; }

accounts=()
for f in "${ACCOUNTS_DIR}"/*.conf; do
    [[ "$(basename "$f")" == "example.conf" ]] && continue
    [[ -f "$f" ]] || continue
    accounts+=("$f")
done

(( ${#accounts[@]} )) || die "No account configs in ${ACCOUNTS_DIR}/. Copy example.conf to get started."

load_account() {
    ACCOUNT="" FULLNAME="" EMAIL="" PASS_ENTRY="" FROM_ADDRESS=""
    TYPE="generic" AUTH="password"
    IMAP_HOST="" IMAP_PORT="993" SMTP_HOST="" SMTP_PORT="587"
    CLIENT_ID="" CLIENT_SECRET="" OAUTH_TENANT="common"

    # shellcheck source=/dev/null
    source "$1"

    FROM_ADDRESS="${FROM_ADDRESS:-${EMAIL}}"

    [[ "${TYPE}" == "gmail" ]] && {
        IMAP_HOST="${IMAP_HOST:-imap.gmail.com}"
        SMTP_HOST="${SMTP_HOST:-smtp.gmail.com}"
    }

    [[ -n "${ACCOUNT}" && -n "${EMAIL}" && -n "${PASS_ENTRY}" ]] \
        || die "$1: ACCOUNT, EMAIL, and PASS_ENTRY are required."
    [[ "${TYPE}" != "generic" || (-n "${IMAP_HOST}" && -n "${SMTP_HOST}") ]] \
        || die "$1: generic type requires IMAP_HOST and SMTP_HOST."
}

gen_aerc() {
    local out="${AERC_DIR}/accounts.conf"

    : > "$out"

    for f in "${accounts[@]}"; do
        load_account "$f"

        local user_encoded="${EMAIL//@/%40}"

        local imap_scheme="imaps"
        [[ "${IMAP_PORT}" == "143" ]] && imap_scheme="imap"

        local smtp_scheme="smtp"
        [[ "${SMTP_PORT}" == "465" ]] && smtp_scheme="smtps"

        local query=""
        case "${AUTH}" in
            google-oauth)
                imap_scheme+="+oauthbearer"; smtp_scheme+="+oauthbearer"
                query="?client_id=${CLIENT_ID}&client_secret=${CLIENT_SECRET}"
                query+="&token_endpoint=https%3A%2F%2Foauth2.googleapis.com%2Ftoken"
                ;;
            microsoft-oauth)
                imap_scheme+="+xoauth2"; smtp_scheme+="+xoauth2"
                query="?client_id=${CLIENT_ID}"
                query+="&token_endpoint=https%3A%2F%2Flogin.microsoftonline.com%2F${OAUTH_TENANT}%2Foauth2%2Fv2.0%2Ftoken"
                ;;
        esac

        cat >> "$out" <<EOF
[${ACCOUNT}]
source            = ${imap_scheme}://${user_encoded}@${IMAP_HOST}:${IMAP_PORT}${query}
source-cred-cmd   = pass show ${PASS_ENTRY}
outgoing          = ${smtp_scheme}://${user_encoded}@${SMTP_HOST}:${SMTP_PORT}${query}
outgoing-cred-cmd = pass show ${PASS_ENTRY}
default           = INBOX
from              = ${FULLNAME} <${FROM_ADDRESS}>
EOF

        if [[ "${TYPE}" == "gmail" ]]; then
            cat >> "$out" <<'EOF'
copy-to           = [Gmail]/Sent Mail
archive           = [Gmail]/All Mail
postpone          = [Gmail]/Drafts
EOF
        else
            cat >> "$out" <<'EOF'
copy-to           = Sent
archive           = Archive
postpone          = Drafts
EOF
        fi

        cat >> "$out" <<'EOF'
check-mail        = 5m
cache-headers     = true
EOF

        if [[ "${FROM_ADDRESS}" != "${EMAIL}" ]]; then
            echo "aliases           = ${FULLNAME} <${EMAIL}>" >> "$out"
        fi

        echo "" >> "$out"
    done

    chmod 600 "$out"
    info "aerc/accounts.conf"
}

echo "Generating configs for ${#accounts[@]} account(s)…"
echo
gen_aerc
echo
info "Done. Launch: aerc"
