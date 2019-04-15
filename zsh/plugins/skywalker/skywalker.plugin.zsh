# ZSH History ignore space
setopt HIST_IGNORE_SPACE

# GNUPG SSH Auth for login to SSH with Yubikey
SSH_AUTH_SOCK=$HOME/.gnupg/S.gpg-agent.ssh; export SSH_AUTH_SOCK;

# Source plugin files
source $ZSH_CUSTOM/plugins/skywalker/env.zsh
source $ZSH_CUSTOM/plugins/skywalker/alias.zsh

# .nvm
export NVM_DIR=$HOME/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

# GOPATH
export GOPATH=$HOME/dev/go
export PATH="$PATH:/usr/local/go/bin:$GOPATH/bin" # Add Go lang PATH

# Shortcut to projects
export DOTFILES=$HOME/.dotfiles
export WORKSPACE=$HOME/dev
export PROJECT=$HOME/dev/projects

# Go Version Manager
#source $HOME/.gvm/scripts/gvm

# Rust env
#source $HOME/.cargo/env

# Global env
source $HOME/.env

# Autojump source
[[ -s /home/s/.autojump/etc/profile.d/autojump.sh ]] && source /home/s/.autojump/etc/profile.d/autojump.sh

autoload -U compinit && compinit -u