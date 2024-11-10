#!/bin/bash
set -e

# Get setup and script root directory
if [ -z "${SETUP_PREFIX}" ]; then
    echo "SETUP_PREFIX is not set or is empty. Defaulting to \${HOME}/Softwares."
    export SETUP_PREFIX='${HOME}/Softwares'
fi
# Set environment variables
# to avoid environment conflict (e.g., zlib, clang), all tools' binary will be
# symlinked to separate directories
ANTS_DIR="$(eval "echo ${SETUP_PREFIX}/neurotools/ants")"
ENV_PREFIX=${ANTS_DIR}/env
# python related
MAMBA_DIR=${MAMBA_DIR:-${SETUP_ROOT}/micromamba}
PATH=${MAMBA_DIR}/bin:${PATH}

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
export PATH=\${ANTS_DIR}/bin:\${PATH}
"
