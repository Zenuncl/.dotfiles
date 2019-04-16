#!/bin/bash

# Install autojump
git clone \
  git://github.com/wting/autojump.git \
  /tmp/autojump/

cd /tmp/autojump/ && \
  ./install.py && \
  cd -

# Install fzf
git clone \
  --depth 1 \
  git://github.com/junegunn/fzf.git \
  $HOME/.fzf

$HOME/.fzf/install

# Install auto-completions
git clone \
  git://github.com/zsh-users/zsh-completions \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-completions

# Install autosuggestion
git clone \
  git://github.com/zsh-users/zsh-autosuggestions \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions


# Install zsh-syntax-highlighting
git clone \
  git://github.com/zsh-users/zsh-syntax-highlighting.git \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
