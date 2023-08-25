#!/bin/bash
set -e

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

# Install packages
# basic
brew install wget curl vim cmake gcc llvm tcl-tk libssh2 open-mpi openblas node swig v8 hdf5 \
    imagemagick sevenzip
# useful utilities
brew install git htop tree pandoc autossh bat lsd thefuck orbstack
brew install gromgit/fuse/sshfs-mac macfuse

# Add following lines into .zshrc
echo "
Add following line to .zshrc

# Alias
# lsd
alias ll=\"lsd -l\"
alias la=\"lsd -a\"
alias lla=\"lsd -la\"
alias lt=\"lsd --tree\"
# bat
alias cat=\"bat\"

eval $(thefuck --alias)
"
