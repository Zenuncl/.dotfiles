#/bin/bash

export DOTFILES=$HOME/.dotfiles

if [ ! -d $DOTFILES ]; then
  git clone git@github.com:SharkIng/.dotfiles.git
fi

# Mike Directory
mkdir -p $HOME/dev/{$USER,repos,go,dockers,scripts,projects,virtualenv}

# change working dir
cd $DOTFILES

# Symlink custome zsh files
ln -fs $DOTFILES/zsh/zshrc.symlink $HOME/.zshrc

ln -fs $DOTFILES/zsh/plugins/skywalker ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/
ln -fs $DOTFILES/zsh/themes/skywalker.zsh-theme ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/

# Install dependency language
$DOTFILES/setup/lang/python.sh
$DOTFILES/setup/lang/ruby.sh

# Install system configs
$DOTFILES/setup/system/plugins.sh
$DOTFILES/setup/system/vim.sh
$DOTFILES/setup/system/tmux.sh

# Install applications (using apt-get need sudo)
sudo $DOTFILES/setup/application/docker.sh
