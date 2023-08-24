#!/usr/bin/env bash

install_nvm() {
  NODE_VIERSION=18.16.1
  NPM_VERSION=9.5.1

  # Install nvm
  \curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
}

if ! [ -d ${HOME}/.nvm ]; then
	install_nvm
fi