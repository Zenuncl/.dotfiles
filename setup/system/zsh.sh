#!/bin/bash

# Install zsh (optional)
apt-get -y update && \
  apt-get -y install \
    zsh

# Setup oh-my-zsh
sh -c "$(curl -fsSL \
  https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Symlink custome files
