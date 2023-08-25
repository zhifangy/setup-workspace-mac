#!/bin/bash
set -e

# Setup
source $( dirname -- "$( readlink -f -- "$0"; )"; )/../envs
# to avoid environment conflict (e.g., zlib, clang), all tools' binary will be
# symlinked to separate directories
FSLEYES_DIR=${SETUP_ROOT}/neurotools/fsleyes
ENV_PREFIX=${FSLEYES_DIR}/env
# python related
MAMBA_DIR=${MAMBA_DIR:-${SETUP_ROOT}/micromamba}
PATH=${MAMBA_DIR}/bin:${PATH}

# Cleanup old installation
if [ $(micromamba env list | grep -c ${ENV_PREFIX}) -ne 0 ]; then
    echo "Cleanup old environment ${ENV_PREFIX}..."
    micromamba env remove -p ${ENV_PREFIX} -yq
fi
if [ -d ${FSLEYES_DIR} ]; then rm -rf ${FSLEYES_DIR}; fi

# Install
echo "Installing FSLeyes from conda-forge..."
micromamba create -p ${ENV_PREFIX} -c conda-forge -yq fsleyes

# Symlink binary files
mkdir -p ${FSLEYES_DIR}/bin
ln -s ${ENV_PREFIX}/bin/fsleyes ${FSLEYES_DIR}/bin/fsleyes

# Put app to /Applications folder
if [[ -d /Applications/FSLeyes.app || -L /Applications/FSLeyes.app ]]; then rm /Applications/FSLeyes.app; fi
ln -s ${ENV_PREFIX}/share/fsleyes/FSLeyes.app /Applications/FSLeyes.app

# Cleanup
micromamba clean -apyq

# Add following lines into .zshrc
echo "
Add following lines to .zshrc:

# FSLeyes
export FSLEYES_DIR=${FSLEYES_DIR}
export PATH=\${FSLEYES_DIR}/bin:\${PATH}
# Note: to use this version of fsleyes
# above lines should be put after FSL related lines
"
