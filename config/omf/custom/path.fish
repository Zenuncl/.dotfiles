# System PATH
set --global --export PATH          $PATH \
                                    /usr/local/bin \
                                    /usr/local/sbin \
                                    /usr/bin \
                                    /usr/sbin \
                                    /bin \
                                    /sbin \
                                    $HOME/.local/bin \
                                    $HOME/.bin \

# Other Custom PATH for Packages
fish_add_path $HOME/.opencode/bin
