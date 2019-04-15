#!/bin/bash

# Init setup to the machine, Default now is Debian 9


# Use the generated debian 9 sources.list
mv /etc/apt/sources.list{,.bak}
cp -rf $(dirname "$0")/deb/stable.sources.list \
  /etc/apt/sources.list

# Install necessary system level dependency
# Upgrade and dist-upgrade
apt-get -y update && \
  apt-get -y upgrade && \
  apt-get -y dist-upgrade

# Suck as: vim, tmux, git. zsh
apt-get -y update && \
  apt-get -y install vim \
    tmux \
    git \
    zsh \
    apt-transport-https \
    ca-certificates \
    curl \
    wget \
    gnupg2 \
    openssh-server \
    sudo \
    net-tools \
    dnsutils
    dirmngr

# Remove uncessary software (optional)
# apt-get -y purge

# Cleanup
apt-get -y autoremove && \
  apt-get -y autoclean

# Add Users
adduser \
  --uid 1116 \
  --shell /bin/zsh \
  --gecos 'SharkIng' \
  --disabled-password \
  --home /home/s \
  sharking

usermod -aG sudo sharking

# Setup password for user
passwd sharking
