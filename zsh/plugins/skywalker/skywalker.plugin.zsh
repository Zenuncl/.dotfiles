# ZSH History ignore space
setopt HIST_IGNORE_SPACE

# Language setting
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# GNUPG SSH Auth for login to SSH with Yubikey
SSH_AUTH_SOCK=$HOME/.gnupg/S.gpg-agent.ssh; export SSH_AUTH_SOCK;

# Source plugin files
source $ZSH_CUSTOM/plugins/skywalker/env.zsh
source $ZSH_CUSTOM/plugins/skywalker/alias.zsh
source $ZSH_CUSTOM/plugins/skywalker/bindkey.zsh
source $ZSH_CUSTOM/plugins/skywalker/tmuxinator.zsh

# .nvm
export NVM_DIR=$HOME/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

# GOPATH
export PATH="$PATH:/usr/local/go/bin:$GOPATH/bin" # Add Go lang PATH

# Go Version Manager
#source $HOME/.gvm/scripts/gvm

# Rust env
#source $HOME/.cargo/env

# Global env
source $HOME/.env

# Autojump source
[[ -s /home/s/.autojump/etc/profile.d/autojump.sh ]] && source /home/s/.autojump/etc/profile.d/autojump.sh

# fasd / fzf source
eval "$(fasd --init auto)"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

autoload -U compinit && compinit -u