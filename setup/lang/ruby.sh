#!/bin/bash

RUBY_VIERSION=2.6.2

# Install RVM
# Add Repo Keys
gpg2 --recv-keys \
  409B6B1796C275462A1703113804BB82D39DC0E3 \
  7D2BAF1CF37B13E2069D6956105BD0E739499BDB

# Install rvm
\curl -sSL https://get.rvm.io | bash -s stable

# Add rvm group to user
usermod -aG rvm sharking

# source rvm (debian)
source $HOME/.rvm/scripts/rvm

# Install ruby + gem
rvm get stable --auto-dotfiles
rvm use $RUBY_VERSION --install --default