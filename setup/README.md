### Use the setup script

Run the `init.sh`` script to install all OS dependencies.
```
(command -v curl && curl -s https://raw.githubusercontent.com/SharkIng/.dotfiles/master/setup/system/00-init.sh | bash) || (command -v wget && wget -qO - https://raw.githubusercontent.com/SharkIng/.dotfiles/master/setup/system/00-init.sh | bash)
```

Other scripts
```
# Install Nerd Font
(command -v curl && curl -s https://raw.githubusercontent.com/SharkIng/.dotfiles/master/setup/system/nerdfont.sh | bash)
(command -v curl && curl -s https://raw.githubusercontent.com/SharkIng/.dotfiles/master/setup/system/nerdfont.sh | bash -s FONTNAME)
```