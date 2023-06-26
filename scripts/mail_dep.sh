#!/bin/zsh

set -e

PKGS=("neomutt" "glow" "isync" "msmtp" "notmuch")

function apt_install() {
        # Install docker dependency
        apt-get -y update && \
                apt-get -y install ${PKGS}
}

function pacman_install() {
        pacman -S --noconfirm ${PKGS}
}

function symlink_configs() {
        ln -sf $HOME/.dotfiles/mail/* $HOME/.config/
}

# Check the Linux distribution
if [ -f "/etc/os-release" ]; then
        # Get the distribution name
        distribution_id=$(awk -F= '/^ID=/{print $2}' /etc/os-release)

                    # Run different commands based on the distribution
                    case "$distribution_id" in
                            "debian")
                                    echo "Running command for Debian"
                                    # Command for Debian
                                    apt_install
                                    ;;
                            "arch")
                                    echo "Running command for Arch Linux"
                                    # Command for Arch Linux
                                    pacman_install
                                    symlink_configs
                                    ;;
                            *)
                                    echo "Unsupported distribution: $distribution"
                                    ;;
                    esac
            else
                    echo "Unable to determine the Linux distribution"
fi
