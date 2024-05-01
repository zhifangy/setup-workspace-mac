#!/bin/bash
set -e

# Install Homebrew
if [ ! -d /opt/homebrew ]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

# Install packages
# basic
brew install wget curl vim cmake gcc llvm tcl-tk libssh2 libgit2 \
    open-mpi openblas node swig v8 hdf5 imagemagick
# useful utilities
brew install git htop btop tree sevenzip pandoc autossh starship fzf bat lsd thefuck
brew install gromgit/fuse/sshfs-mac macfuse
# latest python and r
brew install python r

# Add following lines into .zshrc
echo "
Add following line to .zshrc

# Homebrew
export PATH=\"${HOMEBREW_ROOT}/bin:\${PATH}\"
export HOMEBREW_ROOT=\"${HOMEBREW_ROOT}\"
# Homebrew zsh completions
if type brew &>/dev/null
then
    FPATH=\"\$(brew --prefix)/share/zsh/site-functions:\${FPATH}\"

    autoload -Uz compinit
    compinit
fi

# Starship
eval \"\$(starship init zsh)\"

# bat
export BAT_THEME=\"Dracula\"

# fzf
export PATH=\"/opt/homebrew/opt/fzf/bin:\${PATH}\"
source \"/opt/homebrew/opt/fzf/shell/completion.zsh\"
source \"/opt/homebrew/opt/fzf/shell/key-bindings.zsh\"

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
