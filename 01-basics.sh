#! /bin/bash

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

# Install packages
brew install --cask osxfuse
brew tap AdoptOpenJDK/openjdk
brew install wget vim curl cmake gcc llvm tcl-tk htop tree git libssh2 libgit2 node pandoc hdf5 \
    open-mpi openblas swig sshfs autossh imagemagick netpbm v8 openjdk

# Install R
brew install --cask xquartz
brew install --cask adoptopenjdk
brew tap sethrfore/homebrew-r-srf
brew install -s sethrfore/r-srf/cairo-x11
brew install sethrfore/r-srf/tcl-tk-x11
brew install -s sethrfore/r-srf/r --with-icu4c --with-libtiff --with-openblas --with-openjdk --with-tcl-tk-x11 --with-cairo-x11 --with-texinfo

# Install ZSH
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "
In order to use sshfs, you need to install osxfuse manually.
Then run brew install sshfs
"