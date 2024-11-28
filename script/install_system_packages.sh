#!/bin/bash
set -e

# Install Homebrew
if command -v brew &> /dev/null || [ -d "/opt/homebrew" ]; then
    echo "Homebrew is already installed."
    # check if /opt/homebrew/bin is in the PATH
    if ! echo "$PATH" | grep -q "/opt/homebrew/bin"; then
        echo "However, /opt/homebrew/bin is not in the \$PATH."
        echo "Temporarily add it to \$PATH. Please modify the Shell profile file to make it persistent."
        PATH="/opt/homebrew/bin:$PATH"
    fi
else
    echo "Installing Homebrew ..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install packages
# private tap
brew tap rundel/quarto-cli
# formula packages
formula_packages=(
    "wget" "curl" "vim" "cmake" "gcc" "llvm" "autoconf" "tcl-tk" "pkg-config" "xz" "readline" "gettext" "icu4c" \
    "bzip2" "zlib" "node" "python" "open-mpi" "openblas" "libomp" "tbb" "openjdk" "freetype" "fontconfig" "libiconv" \
    "libpng" "jpeg" "gsl" "expat" "swig" "openmotif" "mesa" "mesa-glu" "libxt" "libxpm" \
    "hdf5" "texinfo" "mariadb-connector-c" "htop" "btop" "tree" "git" "sevenzip" "pandoc" \
    "rundel/quarto-cli/quarto" "autossh" "macfuse" "gromgit/fuse/sshfs-mac" "bash" "bat" "lsd" "fzf" "starship" "thefuck"
)
# cask packages
cask_packages=(
    "xquartz"
)
# install
for package in "${formula_packages[@]}"; do
    brew list --formula "${package}" &> /dev/null || brew install "${package}"
done
for cask in "${cask_packages[@]}"; do
    brew list --cask "${cask}" &> /dev/null || brew install --cask "${cask}"
done
# link packages
brew link quarto

# Add following lines into .zshrc
echo "
Add following line to .zshrc

# Homebrew
eval \"\$(/opt/homebrew/bin/brew shellenv)\"
FPATH=\"\$(brew --prefix)/share/zsh/site-functions:\${FPATH}\"

# Starship
eval \"\$(starship init zsh)\"

# bat
export BAT_THEME=\"Dracula\"

# fzf
# set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

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
