#!/bin/bash

# Install autojump
git clone \
  git://github.com/wting/autojump.git \
  /tmp/autojump/

cd /tmp/autojump/ && \
  ./install.py && \
  cd -

# Install auto-completions
git clone \
  https://github.com/zsh-users/zsh-completions \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-completions

# Install autosuggestion
git clone \
  https://github.com/zsh-users/zsh-autosuggestions \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions


# Install zsh-syntax-highlighting
git clone \
  https://github.com/zsh-users/zsh-syntax-highlighting.git \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
