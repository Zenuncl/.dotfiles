# Disable greeting
set --global fish_greeting

# Environment variable
set --global --export GOPATH $HOME/dev/golang
set --global --export GOROOT $HOME/dev/golang
set --global --export EDITOR /usr/bin/nvim

set --global --export PATH  $PATH \
                            $HOME/.bin \
                            $GOPATH/bin \
                            $GOROOT/bin

# Load Custom files
source $HOME/.config/omf/custom/alias.fish
source $HOME/.config/omf/custom/function.fish
