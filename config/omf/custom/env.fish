# Language setting
set --global --export LC_ALL        en_US.UTF-8
set --global --export LANG          en_US.UTF-8
set --global --export LC_CTYPE      en_US.UTF-8

set --global --export DOTFILES      $HOME/.dotfiles
set --global --export WORKSPACE     $HOME/dev
set --global --export PROJECT       $HOME/dev/projects

# GOPATH
set --global --export GOPATH        $HOME/dev/go

# PATH
set --global --export PATH          $PATH \
                                    /usr/local/bin \
                                    /usr/local/sbin \
                                    /usr/bin \
                                    /usr/sbin \
                                    /bin \
                                    /sbin \
                                    $HOME/.local/bin \
                                    $HOME/.bin \
                                    $GOPATH/bin
