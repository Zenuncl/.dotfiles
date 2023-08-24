#!/bin/zsh

set -e

PKGS=("hugo" "mtr")

function apt_install() {
        # Install docker dependency
        apt-get -y update && \
                apt-get -y install ${PKGS[@]}
}

function pacman_install() {
        pacman -S --noconfirm ${PKGS[@]}
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
                                    ;;
                            *)
                                    echo "Unsupported distribution: $distribution"
                                    ;;
                    esac
            else
                    echo "Unable to determine the Linux distribution"
fi
