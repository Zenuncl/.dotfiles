#!/usr/bin/env bash

DIRECTORY=$HOME/.local/nerdfont
FONT="${1:-SourceCodePro}"

# Check if DIRECTORY exist
if [ ! -d "$DIRECTORY" ]; then
  echo "$DIRECTORY does not exist... Creating..."
  mkdir -p "${DIRECTORY}"
fi

# Clone nerdfont repo
git clone --filter=blob:none --sparse \
  https://github.com/ryanoasis/nerd-fonts.git \
  "$DIRECTORY"

# Install Font
cd "$DIRECTORY" && \
  git sparse-checkout add patched-fonts/$FONT

"$DIRECTORY"/install.sh "$FONT"