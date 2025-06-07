#!/usr/bin/env bash

# Init setup to the machine, Default now support Debian and Arch Linux
set -e

# Variables
DEFAULT_PKGS=("sudo" "git" "zsh" "vim" "neovim" "curl" "wget" "tmux" "fasd" "ca-certificates" "gnupg" "net-tools" "sshpass" "cifs-utils" "unzip" "lynx" "traceroute" "fail2ban" "iptables")
ARCH_PKGS=("base-devel" "openssh" "bind" "qemu-base" "python" "python-pip" "python-virtualenv" "python-pipx")
DEB_PKGS=("build-essential" "openssh-server" "dnsutils" "qemu-utils" "python3" "python3-pip" "python3-virtualenv")

# Running Debian init command part
setup_static_sources_repo() {
	# Use the generated debian 9 sources.list
	if [ -f /etc/apt/sources.list ]; then
		echo "Backing up apt Source file..."
		mv /etc/apt/sources.list{,.original}
		echo "Downloading apt Static Source file..."
		curl -sSL -H 'Cache-Control: no-cache' -o /etc/apt/sources.list \
			"https://github.com/SharkIng/.dotfiles/raw/master/setup/sources/deb/stable.sources.list"
	elif [ -f /etc/pacman.d/mirrorlist ]; then
		echo "Backing up pacman Mirror list..."
		mv /etc/pacman.d/mirrorlist{,.original}
		echo "Downloading Static pacman Mirror list..."
		curl -sSL -H 'Cache-Control: no-cache' -o /etc/pacman.d/mirrorlist \
			"https://raw.githubusercontent.com/SharkIng/.dotfiles/master/setup/sources/arch/global.mirrorlist"
	fi
}

apt_install_dep() {
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
		${DEFAULT_PKGS[@]} ${DEB_PKGS[@]}

	# Cleanup
	apt-get -y autoremove && \
		apt-get -y autoclean
}

apt_purge() {
	# Remove uncessary packages (optional)
	APT_PKGS=$1

	if [[ ${#APT_PKGS} -ne 0 ]]; then
		apt-get purge -y -f \
			"${APT_PKGS}"
	fi
}

# Running Arch Linux init command part
pacman_install() {
	# Install necessary system level dependency

	# Sync pacman repos
	pacman -Sy --noconfirm

	# Upgrade and dist-upgrade
	pacman -Syu --noconfirm

	# Default Packages Such as: vim, tmux, git, zsh
	pacman -S --needed --noconfirm ${DEFAULT_PKGS[@]} ${ARCH_PKGS[@]}

	# Cleanup
	DEPRECATED_PKGS=$(pacman -Qdttq --noconfirm)

	if [ -n "${DEPRECATED_PKGS}" ]; then
		pacman -Rs "${DEPRECATED_PKGS}"
	fi
	pacman -Sc --noconfirm
}

pacman_purge() {
	# Remove uncessary packages (optional)
	PAC_PKGS=$1

	if [[ ${#PAC_PKGS} -ne 0 ]]; then
		pacman -Rns \
			"${PAC_PKGS}"
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
				setup_static_sources_repo
		    pacman_install
		    ;;
	    *)
		    echo "Unsupported distribution: $distribution"
		    ;;
    esac
else
	echo "Unable to determine the Linux distribution"
fi

