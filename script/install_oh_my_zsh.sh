#!/bin/bash
set -e

# Install on-my-zsh
if [ ! -d ~/.oh-my-zsh ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
# Install zsh plugin
if [ ! -d ${ZSH_CUSTOM}/plugins/autoupdate ]; then
    git clone https://github.com/TamCore/autoupdate-oh-my-zsh-plugins ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/autoupdate
fi
if [ ! -d ${ZSH_CUSTOM}/plugins/zsh-autosuggestions ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi
if [ ! -d ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi
if [ ! -d ${ZSH_CUSTOM}/plugins/you-should-use ]; then
    git clone https://github.com/MichaelAquilina/zsh-you-should-use.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/you-should-use
fi
if [ ! -d ${ZSH_CUSTOM}/plugins/zsh-bat ]; then
    git clone https://github.com/fdellwing/zsh-bat.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-bat
fi
if [ ! -d ${ZSH_CUSTOM}/plugins/zsh-abbr ]; then
    git clone https://github.com/olets/zsh-abbr.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-abbr
fi
if [ ! -d ${ZSH_CUSTOM}/themes/powerlevel10k ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k
fi

# Add following lines into .zshrc
echo "
Modify .zshrc:

- Move the 'source $ZSH/oh-my-zsh.sh' command to the end of the .zshrc. If a program has completion files,
    those can be added to the \$FPATH, instead of running compinit multiple times.
- Plugins
    plugins=(\\
        z git sudo aliases macos copyfile copypath safe-paste \\
        autoupdate zsh-autosuggestions zsh-syntax-highlighting you-should-use zsh-bat zsh-abbr \\
        )
- Themes
    ZSH_THEME=\"powerlevel10k/powerlevel10k\"
    # Run 'p10k configure' after restart the shell

Note:
- Fonts
    In order to use the powerlevel10k theme, you need to use fonts from the Nerd-fonts project
    https://github.com/ryanoasis/nerd-fonts
"
