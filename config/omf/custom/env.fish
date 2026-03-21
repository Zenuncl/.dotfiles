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

# Load global .env variable if exist
if test -f $HOME/.secrets/.env
  while read -l line
    # 1. Skip comments and empty lines
    if not string match -q -r '^#|^$' "$line"
        # 2. Split into key and value
        set -l item (string split -m 1 '=' $line)
        set -l key $item[1]
        set -l val $item[2]
  
        # 3. Use eval to expand variables like $HOME
        eval set -gx $key $val
    end
  end < $HOME/.secrets/.env
end
