#!/usr/bin/env bash

git clone --recurse-submodules --remote-submodules \
  --depth 1 -j 2 https://github.com/lcpz/awesome-copycats.git /tmp/awesome && \
  mv -bv /tmp/awesome/{*,.[^.]*} ${HOME}/.config/awesome; rm -rf /tmp/awesome