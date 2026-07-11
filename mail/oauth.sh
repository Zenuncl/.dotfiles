#!/usr/bin/env bash
# One-time OAuth2 device-code flow — obtains a refresh token and stores it in pass.
#
#   bash oauth.sh accounts/gmail.conf
#   bash oauth.sh accounts/outlook.conf
#
# Headless: displays a URL + code you enter on any device (phone, other laptop).
# Requires: curl, jq, pass
set -euo pipefail

GREEN='\033[0;32m'; RED='\033[0;31m'; BOLD='\033[1m'; NC='\033[0m'
info() { echo -e "${GREEN}✓${NC} $*"; }
die()  { echo -e "${RED}✗${NC} $*" >&2; exit 1; }

[[ $# -ge 1 ]] || die "Usage: bash oauth.sh <account.conf>"
[[ -f "$1" ]]   || die "File not found: $1"

AUTH="" EMAIL="" PASS_ENTRY="" CLIENT_ID="" CLIENT_SECRET="" OAUTH_TENANT=""
ACCOUNT="" FULLNAME="" FROM_ADDRESS="" TYPE=""
IMAP_HOST="" IMAP_PORT="" SMTP_HOST="" SMTP_PORT=""

# shellcheck source=/dev/null
source "$1"

[[ "${AUTH}" == "google-oauth" || "${AUTH}" == "microsoft-oauth" ]] \
    || die "AUTH must be google-oauth or microsoft-oauth (got: ${AUTH:-<unset>})"
[[ -n "${EMAIL}" ]]      || die "EMAIL is required"
[[ -n "${PASS_ENTRY}" ]] || die "PASS_ENTRY is required"
[[ -n "${CLIENT_ID}" ]]  || die "CLIENT_ID is required"

for cmd in curl jq pass; do
    command -v "$cmd" &>/dev/null || die "$cmd is required but not found"
done

poll_for_token() {
    local token_url="$1" poll_body="$2" interval="$3" expires_in="$4"

    local deadline=$(($(date +%s) + expires_in))
    while [[ $(date +%s) -lt $deadline ]]; do
        sleep "$interval"

        local resp
        resp=$(curl -s -X POST "$token_url" -d "$poll_body")
        local err
        err=$(echo "$resp" | jq -r '.error // empty')

        if [[ -z "$err" ]]; then
            local rt
            rt=$(echo "$resp" | jq -r '.refresh_token // empty')
            [[ -n "$rt" ]] || die "No refresh_token in response: $resp"
            echo "$rt" | pass insert -m "${PASS_ENTRY}" 2>/dev/null
            echo
            info "Refresh token saved to pass: ${PASS_ENTRY}"
            info "Run 'bash gen.sh' then launch aerc."
            exit 0
        fi

        case "$err" in
            slow_down)             interval=$((interval + 5)) ;;
            authorization_pending) ;;
            *)                     die "Authorization failed: $err" ;;
        esac
    done

    die "Authorization timed out"
}

case "${AUTH}" in
    google-oauth)
        [[ -n "${CLIENT_SECRET}" ]] || die "CLIENT_SECRET is required for Google OAuth"

        resp=$(curl -s -X POST https://oauth2.googleapis.com/device/code \
            -d "client_id=${CLIENT_ID}" \
            -d "scope=https://mail.google.com/")

        device_code=$(echo "$resp" | jq -r '.device_code // empty')
        user_code=$(echo "$resp"   | jq -r '.user_code // empty')
        verify_url=$(echo "$resp"  | jq -r '.verification_url // .verification_uri // empty')
        interval=$(echo "$resp"    | jq -r '.interval // 5')
        expires_in=$(echo "$resp"  | jq -r '.expires_in // 1800')

        [[ -n "$device_code" ]] || die "Failed to get device code: $resp"

        echo
        echo -e "  ${BOLD}Open on any device:${NC}  $verify_url"
        echo -e "  ${BOLD}Enter this code:${NC}     $user_code"
        echo
        echo "  Waiting for authorization (${expires_in}s timeout)..."

        poll_for_token \
            "https://oauth2.googleapis.com/token" \
            "client_id=${CLIENT_ID}&client_secret=${CLIENT_SECRET}&device_code=${device_code}&grant_type=urn:ietf:params:oauth:grant-type:device_code" \
            "$interval" "$expires_in"
        ;;

    microsoft-oauth)
        local_tenant="${OAUTH_TENANT:-common}"

        resp=$(curl -s -X POST "https://login.microsoftonline.com/${local_tenant}/oauth2/v2.0/devicecode" \
            -d "client_id=${CLIENT_ID}" \
            -d "scope=https://outlook.office.com/IMAP.AccessAsUser.All https://outlook.office.com/SMTP.Send offline_access")

        device_code=$(echo "$resp" | jq -r '.device_code // empty')
        message=$(echo "$resp"     | jq -r '.message // empty')
        interval=$(echo "$resp"    | jq -r '.interval // 5')
        expires_in=$(echo "$resp"  | jq -r '.expires_in // 900')

        [[ -n "$device_code" ]] || die "Failed to get device code: $resp"

        echo
        echo "  ${message}"
        echo
        echo "  Waiting for authorization (${expires_in}s timeout)..."

        poll_for_token \
            "https://login.microsoftonline.com/${local_tenant}/oauth2/v2.0/token" \
            "grant_type=urn:ietf:params:oauth:grant-type:device_code&client_id=${CLIENT_ID}&device_code=${device_code}" \
            "$interval" "$expires_in"
        ;;
esac
