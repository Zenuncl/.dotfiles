### Use the setup script

Run the `init.sh`` script to install all OS dependencies.
```
(command -v curl && curl -H 'Cache-Control: no-cache' -s https://raw.githubusercontent.com/SharkIng/.dotfiles/master/setup/system/00-init.sh | bash) || (command -v wget && wget -qO - https://raw.githubusercontent.com/SharkIng/.dotfiles/master/setup/system/00-init.sh | bash)
```

Run add user script when needed
```
~/.dotfiles/setup/system/10-adduser.sh USERNAME
```

Run `boostrap.sh` script to install most dotfiles
```
(command -v curl && curl -H 'Cache-Control: no-cache' -s https://raw.githubusercontent.com/SharkIng/.dotfiles/master/setup/boostrap.sh | bash)
```

Install versional manager
```
# Ruby
~/.dotfiles/setup/system/rvm.sh

# Node
~/.dotfiles/setup/system/nvm.sh

# Go (Coming)
~/.dotfiles/setup/system/gvm.sh

# Python (Coming)
~/.dotfiles/setup/system/pyenv.sh
```

Other scripts (90-*.sh Optional Scripts)
```
# Install Nerd Font
(command -v curl && curl -H 'Cache-Control: no-cache' -s https://raw.githubusercontent.com/SharkIng/.dotfiles/master/setup/system/90-nerdfont.sh | bash)
(command -v curl && curl -H 'Cache-Control: no-cache' -s https://raw.githubusercontent.com/SharkIng/.dotfiles/master/setup/system/90-nerdfont.sh | bash -s FONTNAME)
```