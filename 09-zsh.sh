#! /bin/bash

# Install oh my zsh project
if [ -z ${ZSH} ]
then
cat <<'EOF'
Oh my zsh project is not installed.
Run following command first.
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
EOF
fi

# Install useful plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k

# Tools make the Shell more fancy
brew install lsd thefuck


# Instructions
cat <<EOF


Modify ~/.zshrc:
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
EOF