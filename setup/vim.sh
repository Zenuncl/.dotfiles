#!/bin/bash

# Install vim (optional)
apt-get -y update \
  apt-get -y install \
    vim

# Remove .vim folder
rm -rf $HOME/.vim

# Install .vim dotfile
git clone \
  https://github.com/gpakosz/.vim.git $HOME/.vim

# Setup .vim
ln -s $HOME/.vim/.vimrc $HOME

# Symlink custom file
#cp .vim/.vimrc.local . # use dotfiles local

# Use heavenly branch with add-ons
cd $HOME/.vim && \
  git checkout heavenly && \
  git submodule init && \
  git submodule update

