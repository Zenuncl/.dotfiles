# ZSH History ignore space
setopt HIST_IGNORE_SPACE

# Language setting
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

# Add some PATH
# Add HOME/.bin to PATH
export PATH=$HOME/.bin:$PATH
# Add all bin/sbin to PATH
export PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH
# Add python3 new pipx venv and other local bin
export PATH=$HOME/.local/bin:$PATH

# GNUPG SSH Auth for login to SSH with Yubikey
SSH_AUTH_SOCK=$HOME/.gnupg/S.gpg-agent.ssh; export SSH_AUTH_SOCK;

# ssh-agent
#[ -f "/usr/bin/ssh-agent" ] && eval $(ssh-agent)

# Source plugin files
source $ZSH_CUSTOM/plugins/skywalker/env.zsh
source $ZSH_CUSTOM/plugins/skywalker/alias.zsh
source $ZSH_CUSTOM/plugins/skywalker/bindkey.zsh
source $ZSH_CUSTOM/plugins/skywalker/tmuxinator.zsh

# .gvm / go
[ -s "$HOME/.gvm/scripts/gvm" ] && source "$HOME/.gvm/scripts/gvm"
export GOPATH=$HOME/dev/go

# Rust env
#source $HOME/.cargo/env
export PATH=$HOME/.cargo/bin:$PATH

# Load Global env
[ -f "$HOME/.env" ] && source "$HOME/.env"
[ -f "$HOME/.env.secrets" ] && source "$HOME/.env.secrets"

# Autojump source
#[ -s "$HOME/.autojump/etc/profile.d/autojump.sh" ] && source "$HOME/.autojump/etc/profile.d/autojump.sh"

# bash completion
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Load pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"

# Load customize starship cnfig & start starship
if (( $+commands[starship] )); then
  [ -f "$HOME/.config/starship/starship.toml" ] && export STARSHIP_CONFIG=$HOME/.config/starship/starship.toml

  #[ -f "/usr/bin/starship" ] || [ -f "/usr/local/bin/starship" ] && eval "$(starship init zsh)"
  unset ZSH_THEME
  eval "$(starship init zsh)"
else
  echo "[oh-my-zsh] startship not found, please install it from https://starship.rs"
fi

[ -s "$HOME/.rsvm/rsvm.sh" ] && source "$HOME/.rsvm/rsvm.sh" # This loads RSVM

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

autoload -U compinit && compinit -u
