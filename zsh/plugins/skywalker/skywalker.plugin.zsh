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
[ -f "/usr/bin/ssh-agent" ] && eval $(ssh-agent)

# Source plugin files
source $ZSH_CUSTOM/plugins/skywalker/env.zsh
source $ZSH_CUSTOM/plugins/skywalker/alias.zsh
source $ZSH_CUSTOM/plugins/skywalker/bindkey.zsh
source $ZSH_CUSTOM/plugins/skywalker/tmuxinator.zsh

# .nvm / node
export NVM_DIR=$HOME/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

# .rvm / ruby
[ -s "$HOME/.rvm/scripts/rvm" ] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
export PATH="$PATH:$HOME/.rvm/bin"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

# .gvm / go
[ -s "$HOME/.gvm/scripts/gvm" ] && source "$HOME/.gvm/scripts/gvm"
export GOPATH=$HOME/dev/go

# GOPATH
export PATH="$PATH:/usr/local/go/bin:$GOPATH/bin" # Add Go lang PATH

# Rust env
#source $HOME/.cargo/env

# Load Global env
[ -f "$HOME/.env" ] && source "$HOME/.env"
[ -f "$HOME/.env.secrets" ] && source "$HOME/.env.secrets"

# Autojump source
[ -s "$HOME/.autojump/etc/profile.d/autojump.sh" ] && source "$HOME/.autojump/etc/profile.d/autojump.sh"

# fasd / fzf source
eval "$(fasd --init auto)"
[ -f "$HOME/.fzf.zsh" ] && source "$HOME/.fzf.zsh"

# bash completion
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

autoload -U compinit && compinit -u

# Starship if exits
[ -f "$HOME/.config/starship/startship.toml" ] && export STARSHIP_CONFIG=~/.config/starship/starship.toml
[ -f "/usr/bin/starship" ] && eval $(starship init zsh)
