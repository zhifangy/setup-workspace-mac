#!/bin/bash
set -e

if [ -z ${SETUP_ROOT} ]; then source $( dirname -- "$( readlink -f -- "$0"; )"; )/../envs; fi
# Setup
# to avoid environment conflict (e.g., zlib, clang), all tools' binary will be
# symlinked to separate directories
BASE_DIR=${SETUP_ROOT}/neurotools
FSLEYES_DIR=${BASE_DIR}/fsleyes
ENV_PREFIX=${FSLEYES_DIR}/env

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
rm /Applications/FSLeyes.app
ln -s ${ENV_PREFIX}/share/fsleyes/FSLeyes.app /Applications/FSLeyes.app

# Cleanup
micromamba clean -apyq

# Add following lines into .zshrcx
echo "
Add following lines to .zshrc:

# FSLeyes
export FSLEYES_DIR=${FSLEYES_DIR}
export PATH=\${FSLEYES_DIR}/bin:\${PATH}
# Note: to use this version of fsleyes
# above lines should be put after FSL related lines
"
