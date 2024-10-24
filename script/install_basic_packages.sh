#!/bin/bash
set -e

# Install Homebrew
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install packages
formula_packages=(
    "wget" "curl" "vim" "cmake" "gcc" "llvm" "tcl-tk" "pkg-config" "xz" "readline" "gettext" "icu4c" \
    "bzip2" "zlib" "node" "python" "freetype" "fontconfig" "libssh2" "libgit2" "open-mpi" "openblas" "openjdk" \
    "texinfo" "swig" "v8" "hdf5" "imagemagick" "htop" "btop" "tree" "git" "sevenzip" "pandoc" \
    "autossh" "macfuse" "gromgit/fuse/sshfs-mac" "bat" "lsd" "fzf" "starship" "thefuck"
)
# List of cask packages
cask_packages=(
    "xquartz"
)
for package in "${formula_packages[@]}"; do
    brew list --formula "${package}" &> /dev/null || brew install "${package}"
done
for cask in "${cask_packages[@]}"; do
    brew list --cask "${cask}" &> /dev/null || brew install --cask "${cask}"
done

# Add following lines into .zshrc
echo "
Add following line to .zshrc

# Homebrew
export HOMEBREW_ROOT=\"${HOMEBREW_ROOT}\"
export PATH=\"\${HOMEBREW_ROOT}/bin:\${PATH}\"
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
export PATH=\"\$(brew --prefix fzf)/bin:\${PATH}\"
source \"\$(brew --prefix fzf)/shell/completion.zsh\"
source \"\$(brew --prefix fzf)/shell/key-bindings.zsh\"

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
