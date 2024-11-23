#!/bin/bash
set -e

# Get setup and script root directory
if [ -z "${SETUP_PREFIX}" ]; then
    echo "SETUP_PREFIX is not set or is empty. Defaulting to \${HOME}/Softwares."
    export SETUP_PREFIX='${HOME}/Softwares'
fi
# Set environment variables
export INSTALL_PREFIX="$(eval "echo ${SETUP_PREFIX}/texlive")"
export PATH=${INSTALL_PREFIX}/bin/x86_64-linux:${PATH}

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
export PATH=\"${SETUP_PREFIX}/texlive/bin/x86_64-linux:\${PATH}\"
"
