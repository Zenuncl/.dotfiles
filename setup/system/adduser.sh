#!/bin/bash

# Init setup to the machine.
set -e

USERNAME=$1

# Add Users
useradd -m \
  -u 1027 \
  -s /bin/zsh \
  -p "*" \
  -G wheel \
  ${USERNAME}

echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/$USERNAME
chmod 04400 /etc/sudoers.d/$USERNAME
