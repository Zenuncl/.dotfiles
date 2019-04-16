#!/bin/bash

# Remove old ocker version if any
apt-get -y purge \
  docker \
  docker-engine \
  docker.io \
  containerd \
  runc

# Install docker dependency
apt-get -y install \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg2 \
  dirmngr \
  software-properties-common

# Add repository keys
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -

# Setup repo
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"

# Install docker
apt-get -y update && \
  apt-get -y install \
    docker-ce \
    docker-ce-cli \
    containerd.io

# Post-setup: docker group for user to run none sudo docker
usermod -aG docker $USERNAME
