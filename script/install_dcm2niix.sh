#!/bin/bash
set -e

# Initialize environment
source "$(cd "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/utils.sh" && init_setup
# Set environment variables
INSTALL_PREFIX="$(eval "echo ${INSTALL_ROOT_PREFIX}/dcm2niix")"
ENV_PREFIX=${INSTALL_PREFIX}/env

# Cleanup old installation
command -v micromamba &> /dev/null || { echo "Error: micromamba is not installed." >&2; exit 1; }
if [ $(micromamba env list | grep -c ${ENV_PREFIX}) -ne 0 ]; then
    echo "Cleanup old environment ${ENV_PREFIX}..."
    micromamba env remove -p ${ENV_PREFIX} -yq
fi
if [ -d ${INSTALL_PREFIX} ]; then rm -rf ${INSTALL_PREFIX}; fi

# Install
echo "Installing dcm2niix from conda-forge..."
micromamba create -p ${ENV_PREFIX} -c conda-forge -yq dcm2niix

# Symlink binary files
# to avoid environment conflict (e.g., zlib, clang), all binaries will be symlinked to separate directories
mkdir -p ${INSTALL_PREFIX}/bin
ln -s ${ENV_PREFIX}/bin/dcm2niix ${INSTALL_PREFIX}/bin/dcm2niix

# Cleanup
micromamba clean -yaq

# Add following lines into .zshrc
echo "
Add following lines to .zshrc:

# Dcm2niix
export PATH=\"${INSTALL_ROOT_PREFIX}/dcm2niix/bin:\${PATH}\"
"
