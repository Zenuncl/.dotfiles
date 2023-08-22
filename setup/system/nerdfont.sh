#!/bin/bash

DIRECTORY=$HOME/.local/nerdfont
DEFAULT_FONT="SourceCodePro"

# Check if DIRECTORY exist
if [ ! -d "$DIRECTORY" ]; then
  echo "$DIRECTORY does not exist... Creating..."
  mkdir -p ${DIRECTORY}
fi

# Clone nerdfont repo
git clone \
  https://github.com/ryanoasis/nerd-fonts.git \
  $DIRECTORY

# Install Font
$DIRECTORY/install.sh $DEFAULT_FONT
