#!/bin/bash

# Remove old .tmux dotfiles
rm -rf $HOME/.tmux

# Install .vim dotfiles
git clone \
  https://github.com/gpakosz/.tmux.git \
  $HOME/.tmux

# Setup .vim
ln -s -f $HOME/.tmux/.tmux.conf $HOME

# Symlink custom file
ln -fs $HOME/.dotfiles/tmux/tmux.conf.local.symlink $HOME/.tmux.conf.local # use dotfiles local
