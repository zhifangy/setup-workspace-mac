#! /bin/bash

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

# Install packages
brew tap AdoptOpenJDK/openjdk
brew install wget vim curl cmake gcc llvm tcl-tk htop tree git libssh2 libgit2 node pandoc hdf5 \
    open-mpi openblas swig autossh imagemagick netpbm v8 openjdk macfuse harfbuzz fribidi mariadb-connector-c
brew install gromgit/fuse/sshfs-mac

# Install R
brew install --cask xquartz
brew install --cask adoptopenjdk
brew tap sethrfore/homebrew-r-srf
brew install -s sethrfore/r-srf/cairo-x11
brew install sethrfore/r-srf/tcl-tk-x11
brew install -s sethrfore/r-srf/r --with-icu4c --with-libtiff --with-openblas --with-openjdk --with-tcl-tk-x11 --with-cairo-x11 --with-texinfo
# Fix compilation executable for objective c++
sed -i "" "s/OBJCXX =.*/OBJCXX = clang++/" $(brew --prefix r)/lib/R/etc/Makeconf

# Install ZSH
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "
Add following line to .zshrc

# Compilation environment
export PATH="/usr/local/opt/llvm/bin:\${PATH}"
export LDFLAGS="-L/usr/local/opt/llvm/lib -Wl,-rpath,/usr/local/opt/llvm/lib \$LDFLAGS"
export CPPFLAGS="-I/usr/local/opt/llvm/include \$CPPFLAGS"
"