#!/bin/bash
set -e

# Initialize environment
source "$(cd "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/utils.sh" && init_setup
# Set environment variables
INSTALL_PREFIX="$(eval "echo ${INSTALL_ROOT_PREFIX}/texlive")"
if [ "$OS_TYPE" == "macos" ]; then
    TEXLIVE_VERSION=universal-darwin
elif [ "$OS_TYPE" == "rhel8" ]; then
    TEXLIVE_VERSION=x86_64-linux
fi
export PATH=${INSTALL_PREFIX}/bin/universal-darwin:${PATH}

# Cleanup old installation
if [ -d ${INSTALL_PREFIX} ]; then echo "Cleanup old Texlive installation..." && rm -rf ${INSTALL_PREFIX}; fi

# Install
mkdir -p ${INSTALL_PREFIX}
wget -q https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz -P ${INSTALL_PREFIX}
zcat < ${INSTALL_PREFIX}/install-tl-unx.tar.gz | tar xf - -C ${INSTALL_PREFIX}
perl ${INSTALL_PREFIX}/install-tl-*/install-tl -no-interaction -no-continue \
    --scheme=scheme-bookpub \
    -texdir=${INSTALL_PREFIX} \
    -texuserdir=${INSTALL_PREFIX}/texmf-user

# Install additional packages
tlmgr install xetex
# for R documentation build)
tlmgr install inconsolata fancyvrb

# Cleanup
rm -r ${INSTALL_PREFIX}/install-tl-*

# Add following lines into .zshrc
echo "
Add following lines to .zshrc:

# TeX Live
export PATH=\"${INSTALL_ROOT_PREFIX}/texlive/bin/${TEXLIVE_VERSION}:\${PATH}\"
"
