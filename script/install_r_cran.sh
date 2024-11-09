#!/bin/bash
set -e

# Install R
brew list --cask r &> /dev/null || brew install --cask r

# Add following lines into .zshrc
echo "
Add following lines to .zshrc:

# R
export R_EXE=\"/usr/local/bin/R\"
alias R=\"R --no-save --no-restore\"
"
