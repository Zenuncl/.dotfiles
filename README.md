
### Manual commands
Install `tmuxinator` after `ruby + gem` installed through `rvm`

`gem install tmuxinator`


```
# Install Ruby
source ${HOME}/.rvm/scripts/rvm
# update rvm
rvm get stable --auto-dotfiles
# Install ruby + gem
rvm use $RUBY_VERSION --install --default
```

### A list of programs that not in scripts
```
sudo pacman -S \
    rofi # Menu
    remmina $ RDP
    nitrogen # for wallpaper
```

### Running BATS tests

Install the `bats` executable and then run:

```
bats tests
```

