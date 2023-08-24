#!/usr/bin/env bash

set -e

PKGS=("hugo" "mtr")

install() {
        ~/.dotfiles/bin/pacapt -S --noconfirm ${PKGS[@]}
}

install