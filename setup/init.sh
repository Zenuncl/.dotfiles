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
    dnsutils \
    dirmngr \
    python \
    python3 \
    python-pip \
    python3-pip

# Remove uncessary software (optional)
# apt-get -y purge

# Cleanup
apt-get -y autoremove && \
  apt-get -y autoclean

read -p "Please choose your username" USERNAME
read -p "Please choose your home directory" HOMEDIR
read -p "Please choose your UID" UID

# Add Users
adduser \
  --uid ${UID} \
  --shell /bin/zsh \
  --gecos '${USERNAME}' \
  --disabled-password \
  --home ${HOMEDIR:-/home/s} \
  $USERNAME

usermod -aG sudo ${USERNAME}

# Setup password for user
passwd ${USERNAME}
