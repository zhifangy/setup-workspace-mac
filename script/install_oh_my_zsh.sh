#!/bin/bash
set -e

# Install on-my-zsh
if [ ! -d ~/.oh-my-zsh ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
# Install zsh plugin
if [ ! -d ~/.oh-my-zsh/custom/plugins/autoupdate ]; then
    git clone https://github.com/TamCore/autoupdate-oh-my-zsh-plugins ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/autoupdate
fi
if [ ! -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi
if [ ! -d ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi
if [ ! -d ~/.oh-my-zsh/custom/plugins/zsh-abbr ]; then
    git clone https://github.com/olets/zsh-abbr.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-abbr
fi
if [ ! -d ~/.oh-my-zsh/custom/themes/powerlevel10k ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k
fi

# Add following lines into .zshrc
echo "
Modify .zshrc:

1.Plugins
    plugins=(git z sudo autoupdate zsh-autosuggestions zsh-syntax-highlighting zsh-abbr)
2.Themes
    ZSH_THEME=\"powerlevel10k/powerlevel10k\"
    # Run 'p10k configure' after restart the shell
3.Fonts
    In order to use the powerlevel10k theme, you need to use fonts from the Nerd-fonts project
    https://github.com/ryanoasis/nerd-fonts
"
