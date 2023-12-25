#!/bin/bash
set -e

# Install Homebrew
if [ ! -d /opt/homebrew ]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

# Install packages
# basic
brew install wget curl vim cmake gcc llvm tcl-tk libssh2 open-mpi openblas node swig v8 hdf5 \
    imagemagick sevenzip
# useful utilities
brew install git htop tree pandoc autossh starship bat lsd thefuck
brew install gromgit/fuse/sshfs-mac macfuse

# Add following lines into .zshrc
echo "
Add following line to .zshrc

# Homebrew
export PATH=\"/opt/homebrew/bin:\${PATH}\"
# Homebrew zsh completions
if type brew &>/dev/null
then
    FPATH=\"\$(brew --prefix)/share/zsh/site-functions:\${FPATH}\"

    autoload -Uz compinit
    compinit
fi

# Starship
eval \"\$(starship init zsh)\"

# The fuck
eval \"\$(thefuck --alias)\"

# Alias
# lsd
alias ll=\"lsd -l\"
alias la=\"lsd -a\"
alias lla=\"lsd -la\"
alias lt=\"lsd --tree\"
# bat
alias cat=\"bat\"
"
