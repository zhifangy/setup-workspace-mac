#!/bin/bash
set -e

# Setup
source $( dirname -- "$( readlink -f -- "$0"; )"; )/../envs
# TeX Live
TEXLIVE_DIR=${SETUP_ROOT}/texlive
export PATH=${TEXLIVE_DIR}/bin/universal-darwin:${PATH}

# Cleanup old installation
if [ -d ${TEXLIVE_DIR} ]; then echo "Cleanup old Texlive installation..." && rm -rf ${TEXLIVE_DIR}; fi

# Install
mkdir -p ${TEXLIVE_DIR}
wget -q https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz -P ${TEXLIVE_DIR}
zcat < ${TEXLIVE_DIR}/install-tl-unx.tar.gz | tar xf - -C ${TEXLIVE_DIR}
perl ${TEXLIVE_DIR}/install-tl-*/install-tl -no-interaction -no-continue \
    --scheme=scheme-bookpub \
    -texdir=${TEXLIVE_DIR} \
    -texuserdir=${TEXLIVE_DIR}/texmf-user

# Install additional packages
tlmgr install xetex
# for R documentation build)
tlmgr install inconsolata fancyvrb

# Cleanup
rm -r ${TEXLIVE_DIR}/install-tl-*

# Add following lines into .zshrc
echo "
Add following lines to .zshrc:

# TeX Live
export PATH=${TEXLIVE_DIR}/bin/universal-darwin:\${PATH}
"