#!/usr/bin/env bash

# Init setup to the machine, Default now support Debian and Arch Linux
set -e

# Veriables
PKGS="sudo git zsh vim neovim build-essential curl wget tmux fasd ca-certificates gnupg gnupg2 openssh-server net-tools dnsutils sshpass dirmgr cifs-utils qemu-utils python python-pip python-virtualenv python-pipx"

# Running Debian init command part
function setup_static_sources_repo() {
	# Use the generated debian 9 sources.list
	if [ -f /etc/apt/sources.list ]; then
		mv /etc/apt/sources.list{,.bak}
	fi
	curl -sSL -H 'Cache-Control: no-cache' -o /etc/apt/sources.list \
		"https://github.com/SharkIng/.dotfiles/raw/master/setup/deb/stable.sources.list"
}

function apt_install_dep() {
	# Install necessary system level dependency
	# Upgrade and dist-upgrade
	apt-get -y update && apt-get -y -f \
		-o Dpkg::Options::="--force-confdef" \
		-o Dpkg::Options::="--force-confold" \
		upgrade && apt-get -y -f \
		-o Dpkg::Options::="--force-confdef" \
		-o Dpkg::Options::="--force-confold" \
		dist-upgrade

	# Such as: vim, tmux, git. zsh
	apt-get -y update && apt-get install -y -f \
		-o Dpkg::Options::="--force-confdef" \
		-o Dpkg::Options::="--force-confold" \
		sudo \
		git \
		zsh \
		build-essential \
		rsync \
		vim \
		tmux \
		fasd \
		apt-transport-https \
		ca-certificates \
		curl \
		wget \
		gnupg2 \
		openssh-server \
		net-tools \
		dnsutils \
		sshpass \
		dirmngr \
		cifs-utils \
		qemu-utils \
		python3 \
		python3-pip \
		python3-virtualenv

	# Cleanup
	apt-get -y autoremove && \
		apt-get -y autoclean
}

function apt_purge_dep() {
	# Remove uncessary packages (optional)
	APT_PKGS=$1

	if [[ ${#APT_PKGS} -ne 0 ]]; then
		apt-get purge -y -f \
			${APT_PKGS}
	fi
}

# Running Arch Linux init command part
function pacman_install_dep() {
	# Install necessary system level dependency
	# Upgrade and dist-upgrade
	pacman -Syu --noconfirm

	# Such as: vim, tmux, git, zsh
	pacman -S --noconfirm \
		sudo \
		git \
		zsh \
		base-devel \
		which \
		rsync \
		htop \
		coreutils \
		vim \
		neovim \
		tmux \
		ca-certificates \
		curl \
		fasd \
		go \
		wget \
		gnupg \
		openssh \
		net-tools \
		dnsutils \
		sshpass \
		cifs-utils \
		qemu-base \
		python \
		python3 \
		python-pip \
		python-pipx \
		python-virtualenv

	# Cleanup
	DEPRECATED_PKGS=$(pacman -Qdttq --noconfirm)

	if [[ -n "$DEPRECATED_PKGS" ]]; then
		pacman -Rs "$DEPRECATED_PKGS"
	fi
	pacman -Sc --noconfirm

}

function pacman_purge_dep() {
	# Remove uncessary packages (optional)
	PAC_PKGS=$1

	if [[ ${#PAC_PKGS} -ne 0 ]]; then
		pacman -Rns \
			${PAC_PKGS}
	fi
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
		    setup_static_sources_repo
		    apt_install_dep
		    ;;
	    "arch")
		    echo "Running command for Arch Linux"
		    # Command for Arch Linux
		    pacman_install_dep
		    ;;
	    *)
		    echo "Unsupported distribution: $distribution"
		    ;;
    esac
else
	echo "Unable to determine the Linux distribution"
fi

