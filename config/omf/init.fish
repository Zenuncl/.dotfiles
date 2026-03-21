# Disable greeting
set --global fish_greeting

# Environment variable
set --global --export EDITOR  /usr/bin/nvim

set --global --export PATH    $HOME/.bin \
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

# Load SSH Keys to ssh-agent with ssh-add
source $HOME/.config/omf/custom/ssh.fish
