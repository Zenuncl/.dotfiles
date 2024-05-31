packagesPacman=(
  "hyprland"
  "hyprpaper"
  "hyprlock"
  "hypridle"
  "xdg-desktop-portal-hyprland"
  "xorg-xwayland"
  "waybar"
  "mako"
  "grim"
  "slurp"
  "swappy"
  "cliphist"
  "blueman"
  "networkmanager"
  "fcitx5"
  "btop"
  "yazi"
  "thunar"
  "flameshot"
  "imv"
  "neovim"
  "mpv"
  "kitty"
  "copyq"
  )

packagesYay=(
  "wlogout"
  "eww"
  "lightdm-settings"
  "anyrun-git"
  )



pacman --noconfirm --needed -S ${packagesPacman}

yay --noconfirm --needed -S ${packagesYay}
