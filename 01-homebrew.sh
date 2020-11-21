#! /bin/bash

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

# Install packages
brew cask install osxfuse
brew tap AdoptOpenJDK/openjdk
brew install wget vim curl cmake gcc llvm tcl-tk htop tree git libssh2 libgit2 node pandoc hdf5 \
    open-mpi openblas swig sshfs autossh imagemagick netpbm v8 openjdk

# Install R
brew cask install xquartz
brew cask install adoptopenjdk
brew tap sethrfore/homebrew-r-srf
brew install -f -s sethrfore/r-srf/cairo
brew install -s sethrfore/r-srf/r --with-openblas --with-java --with-texinfo --with-cairo --with-libtiff --with-icu4c