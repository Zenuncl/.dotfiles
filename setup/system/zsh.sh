#!/bin/bash

sh -c "$(curl -fsSL \
  https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Symlink custome files
ln -fs $HOME/.dotfiles/zsh/zshrc.symlink $HOME/.zshrc

ln -fs $HOME/.dotfiles/zsh/plugins/skywalker ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/
ln -fs $HOME/.dotfiles/zsh/themes/skywalker.zsh-theme ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/