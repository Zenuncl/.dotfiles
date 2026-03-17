#!/usr/bin/env bash
# Install latest kubectl — binary download from dl.k8s.io with checksum verification
# Note: The old kubernetes-xenial apt repo is EOL. Official recommendation is now
#       the pkgs.k8s.io repo or direct binary download. We use binary download
#       to stay version-independent and avoid apt repo pinning.
set -euo pipefail

RED='\033[0;31m'; YELLOW='\033[1;33m'; GREEN='\033[0;32m'; NC='\033[0m'
info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# ─── Architecture ─────────────────────────────────────────────────────────────

ARCH="$(uname -m)"
case "${ARCH}" in
    x86_64)  KUBE_ARCH="amd64" ;;
    aarch64) KUBE_ARCH="arm64" ;;
    *) error "Unsupported architecture: ${ARCH}"; exit 1 ;;
esac

# ─── Resolve latest stable version ───────────────────────────────────────────

info "Resolving latest stable kubectl version…"
KUBE_VERSION="$(curl -fsSL https://dl.k8s.io/release/stable.txt)"
info "Latest version: ${KUBE_VERSION}"

# ─── Download & verify ────────────────────────────────────────────────────────

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

BASE_URL="https://dl.k8s.io/release/${KUBE_VERSION}/bin/linux/${KUBE_ARCH}"

info "Downloading kubectl…"
curl -fsSL "${BASE_URL}/kubectl"        -o "${TMP_DIR}/kubectl"
curl -fsSL "${BASE_URL}/kubectl.sha256" -o "${TMP_DIR}/kubectl.sha256"

info "Verifying checksum…"
echo "$(cat "${TMP_DIR}/kubectl.sha256")  ${TMP_DIR}/kubectl" | sha256sum --check --quiet \
    && info "Checksum OK." \
    || { error "Checksum mismatch — aborting."; exit 1; }

# ─── Install ──────────────────────────────────────────────────────────────────

install -o root -g root -m 0755 "${TMP_DIR}/kubectl" /usr/local/bin/kubectl

info "Done. $(kubectl version --client --output=yaml | grep gitVersion)"
