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

# Install on-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# Install zsh plugin
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k

echo "
Add following line to .zshrc

Modify .zshrc:
1.Plugins
    plugins=(git brew z zsh-autosuggestions zsh-syntax-highlighting)
2.Themes
    ZSH_THEME="powerlevel10k/powerlevel10k"
3.Fonts
    In order to use the powerlevel10k theme, you need to use fonts from the Nerd-fonts project
    https://github.com/ryanoasis/nerd-fonts
4. More alias
    alias ll="lsd -l"
    alias la="lsd -a"
    alias lla="lsd -la"
    alias lt="lsd --tree"
5. More good stuff
    eval $(thefuck --alias)
"
