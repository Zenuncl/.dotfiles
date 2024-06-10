#!/usr/bin/env bash

set -e

USERNAME=$1

function apt_install_docker() {
  # Remove old ocker version if any
  # apt-get -y purge --ignore-missing \
  #   docker \
  #   docker-compose \
  #   docker-doc \
  #   podman-docker \
  #   docker-engine \
  #   docker.io \
  #   containerd \
  #   runc

  # Install docker dependency
  apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    dirmngr \
    software-properties-common

  # Add repository keys
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg

  # Setup repo
  echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null

  apt-get -y update && \
    apt-get -y install \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

  # Post-setup: docker group for user to run none sudo docker
  usermod -aG docker $USERNAME
}

function pacman_install_docker() {
  pacman -S docker --noconfirm
  usermod -aG docker $USERNAME
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
                    apt_install_docker
                    ;;
            "arch")
                    echo "Running command for Arch Linux"
                    # Command for Arch Linux
                    pacman_install_docker
                    ;;
            *)
                    echo "Unsupported distribution: $distribution"
                    ;;
    esac
else
        echo "Unable to determine the Linux distribution"
fi

