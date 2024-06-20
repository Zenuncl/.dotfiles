# Disable greeting
set --global fish_greeting

# Environment variable
set --global --export EDITOR  /usr/bin/nvim

set --global --export PATH    $PATH \
                              $HOME/.bin \
                              $GOPATH/bin

# Load Custom files
source $HOME/.config/omf/custom/alias.fish
source $HOME/.config/omf/custom/function.fish

# Load Starship plugin
source $HOME/.config/omf/custom/starship.fish

ssh-add $HOME/.ssh/secrets/keys.sec/github.ed25519.pem
