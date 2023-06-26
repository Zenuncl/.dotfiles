#!/bin/zsh

set -e

PKGS="aws linode-cli"

function pipx_install() {
        pipx install $PKGS
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
                                    pipx_install
                                    ;;
                            "arch")
                                    echo "Running command for Arch Linux"
                                    # Command for Arch Linux
                                    pipx_install
                                    ;;
                            *)
                                    echo "Unsupported distribution: $distribution"
                                    ;;
                    esac
            else
                    echo "Unable to determine the Linux distribution"
fi
