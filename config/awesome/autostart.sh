#!/usr/bin/env bash
#

function run {
  if ! pgrep -f $1;
  then
    $@&
  fi
}

# Autostart picom for transparent
run picom -b --config $HOME/.config/picom/picom.conf

# Autostart clipmenu
run clipmenud

# Autostart Fcitx5
run fcitx5-remote -r
