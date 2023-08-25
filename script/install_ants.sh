#!/bin/bash
set -e

if [ -z ${SETUP_ROOT} ]; then source $( dirname -- "$( readlink -f -- "$0"; )"; )/../envs; fi
# Setup
# to avoid environment conflict (e.g., zlib, clang), all tools' binary will be
# symlinked to separate directories
BASE_DIR=${SETUP_ROOT}/neurotools
ANTS_DIR=${BASE_DIR}/ants
ENV_PREFIX=${ANTS_DIR}/env

# Cleanup old installation
if [ $(micromamba env list | grep -c ${ENV_PREFIX}) -ne 0 ]; then
    echo "Cleanup old environment ${ENV_PREFIX}..."
    micromamba env remove -p ${ENV_PREFIX} -yq
fi
if [ -d ${ANTS_DIR} ]; then rm -rf ${ANTS_DIR}; fi

# Install
echo "Installing ANTs from conda-forge..."
micromamba create -p ${ENV_PREFIX} -c conda-forge -yq ants

# Symlink binary files
mkdir -p ${ANTS_DIR}/bin
FILE_LIST=$(grep -v "_path" $(ls ${ENV_PREFIX}/conda-meta/ants*) | grep -o "bin.*[A-Z|a-z|0-9]")
while IFS='' read -r p; do
    ln -s ${ENV_PREFIX}/${p} ${ANTS_DIR}/${p}
done < <(printf '%s\n' "$FILE_LIST")

# Cleanup
micromamba clean -apyq

# Add following lines into .zshrc
echo "
Add following lines to .zshrc:

# ANTs
export ANTS_DIR=${ANTS_DIR}
export ANTSPATH=\${ANTS_DIR}/bin
export PATH=\${ANTSPATH}:\${PATH}
"
