#!/usr/bin/env bash
# Install AWS CLI v2 (latest) — official installer, supports update in-place
set -euo pipefail

RED='\033[0;31m'; YELLOW='\033[1;33m'; GREEN='\033[0;32m'; NC='\033[0m'
info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# ─── Architecture ─────────────────────────────────────────────────────────────

ARCH="$(uname -m)"
case "${ARCH}" in
    x86_64)  AWS_ARCH="x86_64" ;;
    aarch64) AWS_ARCH="aarch64" ;;
    *) error "Unsupported architecture: ${ARCH}"; exit 1 ;;
esac

# ─── Download ─────────────────────────────────────────────────────────────────

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

ZIP="${TMP_DIR}/awscliv2.zip"
SIG="${TMP_DIR}/awscliv2.zip.sig"

info "Downloading AWS CLI v2 (${AWS_ARCH})…"
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${AWS_ARCH}.zip"     -o "${ZIP}"
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${AWS_ARCH}.zip.sig" -o "${SIG}"

# ─── Signature verification ───────────────────────────────────────────────────

if command -v gpg &>/dev/null; then
    info "Verifying signature…"
    gpg --keyserver hkps://keys.openpgp.org \
        --recv-keys FB5DB77FD5C118B80511ADA8A6310ACC4672475C 2>/dev/null || true
    gpg --verify "${SIG}" "${ZIP}" 2>/dev/null \
        && info "Signature OK." \
        || { error "Signature verification failed — aborting."; exit 1; }
else
    warn "gpg not found — skipping signature verification."
fi

# ─── Install ──────────────────────────────────────────────────────────────────

info "Extracting…"
unzip -q "${ZIP}" -d "${TMP_DIR}"

info "Installing / updating AWS CLI…"
"${TMP_DIR}/aws/install" --update

info "Done. $(aws --version)"
