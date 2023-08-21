#!/bin/bash
set -e

if [ -z ${SETUP_ROOT} ]; then source $( dirname -- "$( readlink -f -- "$0"; )"; )/../envs; fi
# Setup
# to avoid environment conflict (e.g., zlib, clang), all tools' binary will be
# symlinked to separate directories
BASE_DIR=${SETUP_ROOT}/neurotools
DCM2NIIX_DIR=${BASE_DIR}/dcm2niix
ENV_PREFIX=${DCM2NIIX_DIR}/env

# Cleanup old installation
if [ $(micromamba env list | grep -c ${ENV_PREFIX}) -ne 0 ]; then
    echo "Cleanup old environment ${ENV_PREFIX}..."
    micromamba env remove -p ${ENV_PREFIX} -yq
fi
if [ -d ${DCM2NIIX_DIR} ]; then rm -rf ${DCM2NIIX_DIR}; fi

# Install
echo "Installing dcm2niix from conda-forge..."
micromamba create -p ${ENV_PREFIX} -c conda-forge -yq dcm2niix

# Symlink binary files
mkdir -p ${DCM2NIIX_DIR}/bin
ln -s ${ENV_PREFIX}/bin/dcm2niix ${DCM2NIIX_DIR}/bin/dcm2niix

# Cleanup
micromamba clean -apyq

# Add following lines into .zshrcx
echo "
Add following lines to .zshrc:

# Dcm2niix
export DCM2NIIX_DIR=${DCM2NIIX_DIR}
export PATH=\${DCM2NIIX_DIR}/bin:\${PATH}
"
