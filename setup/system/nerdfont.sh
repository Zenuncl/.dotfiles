#!/bin/sh

DIRECTORY=$HOME/.local/nerdfont
DEFAULT_FONT="SourceCodePro"

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
  git sparse-checkout add patched-fonts/$DEFAULT_FONT

"$DIRECTORY"/install.sh "$DEFAULT_FONT"
