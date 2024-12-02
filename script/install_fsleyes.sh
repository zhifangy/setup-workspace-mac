#!/bin/bash
set -e

# Initialize environment
source "$(cd "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/utils.sh" && init_setup
# Set environment variables
INSTALL_PREFIX="$(eval "echo ${INSTALL_ROOT_PREFIX}/fsleyes")"
ENV_PREFIX=${INSTALL_PREFIX}/env

# Cleanup old installation
command -v micromamba &> /dev/null || { echo "Error: Mircomamba is not installed or not included in the PATH." >&2; exit 1; }
if [ $(micromamba env list | grep -c ${ENV_PREFIX}) -ne 0 ]; then
    echo "Cleanup old environment ${ENV_PREFIX}..."
    micromamba env remove -p ${ENV_PREFIX} -yq
fi
if [ -d ${INSTALL_PREFIX} ]; then rm -rf ${INSTALL_PREFIX}; fi

# Install
echo "Installing FSLeyes from conda-forge..."
micromamba create -p ${ENV_PREFIX} -c conda-forge -yq fsleyes

# Symlink binary files
# to avoid environment conflict (e.g., zlib, clang), all binaries will be symlinked to separate directories
mkdir -p ${INSTALL_PREFIX}/bin
ln -s ${ENV_PREFIX}/bin/fsleyes ${INSTALL_PREFIX}/bin/fsleyes

if [ "$OS_TYPE" == "macos" ]; then
    # Put app to /Applications folder
    if [[ -d /Applications/FSLeyes.app || -L /Applications/FSLeyes.app ]]; then rm /Applications/FSLeyes.app; fi
    ln -s ${ENV_PREFIX}/share/fsleyes/FSLeyes.app /Applications/FSLeyes.app
fi

# Cleanup
micromamba clean -yaq

# Add following lines into .zshrc
echo "
Add following lines to .zshrc:

# FSLeyes
export PATH=\"${INSTALL_ROOT_PREFIX}/fsleyes/bin:\${PATH}\"
# Note: to use this version of fsleyes
# above lines should be put after FSL related lines
"
