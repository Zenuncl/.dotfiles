#!/usr/bin/env zsh

install_via_manager() {
  local packages=( $@ )
  local package

  for package in ${packages[@]}; do
    brew install ${package} || \
      apt install -y ${package} || \
      apt-get install -y ${package} || \
      yum -y install ${package} || \
      pacman -S --noconfirm ${package} ||
      true
  done
}