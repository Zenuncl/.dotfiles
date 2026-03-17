#!/usr/bin/env bash

# Init setup to the machine.
set -e

USERNAME="${1:-anonymous}"

# Add Users
useradd -m \
  -u 1027 \
  -s /bin/zsh \
  -G "$(getent group wheel > /dev/null && echo wheel || echo sudo)" \
  ${USERNAME}

echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/$USERNAME
chmod 04400 /etc/sudoers.d/$USERNAME
