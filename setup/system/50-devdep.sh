#!/usr/bin/env bash

set -e

PKGS=("hugo" "mtr" "firefox" "vscode")

install() {
        ~/.dotfiles/bin/pacapt -S --noconfirm ${PKGS[@]}
}

install
