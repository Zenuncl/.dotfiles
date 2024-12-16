# Disable greeting
set --global fish_greeting

# Environment variable
set --global --export EDITOR  /usr/bin/nvim

set --global --export PATH    $HOME/.bin \
                              $GOPATH/bin \
                              $PATH

# Load Custom files
source $HOME/.config/omf/custom/env.fish
source $HOME/.config/omf/custom/alias.fish
source $HOME/.config/omf/custom/function.fish

# Load Starship plugin
source $HOME/.config/omf/custom/starship.fish

# Load curlie plugin
#source $HOME/.config/envman/load.fish
source $HOME/.config/omf/custom/mise.fish

ssh-add $HOME/.ssh/secrets/keys.sec/github.ed25519.pem
