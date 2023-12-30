#!/bin/bash
set -e

# Install Homebrew
if [ ! -d /usr/local/homebrew ]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

# Install packages
# basic
brew install wget curl vim cmake gcc llvm tcl-tk libssh2 open-mpi openblas node swig v8 hdf5 \
    imagemagick sevenzip
# useful utilities
brew install git htop tree pandoc autossh starship fzf bat lsd thefuck
brew install gromgit/fuse/sshfs-mac macfuse
# latest python and r
brew install python r

# Add following lines into .zshrc
echo "
Add following line to .zshrc

# Starship
eval \"\$(starship init zsh)\"

# bat
export BAT_THEME=\"Dracula\"

# fzf
source /usr/local/Cellar/fzf/*/shell/completion.zsh
source /usr/local/Cellar/fzf/*/shell/key-bindings.zsh

# The fuck
eval \"\$(thefuck --alias)\"

# Alias
# lsd
alias ll=\"lsd -l\"
alias la=\"lsd -a\"
alias lla=\"lsd -la\"
alias lt=\"lsd --tree\"
alias llsize=\"lsd -l --total-size\"
# fzf
alias preview=\"fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'\"
"
