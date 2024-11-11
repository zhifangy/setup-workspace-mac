#!/bin/bash
set -e

# Get setup and script root directory
if [ -z "${SETUP_PREFIX}" ]; then
    echo "SETUP_PREFIX is not set or is empty. Defaulting to \${HOME}/Softwares."
    export SETUP_PREFIX='${HOME}/Softwares'
fi
# Set environment variables
INSTALL_PREFIX="$(eval "echo ${SETUP_PREFIX}/fsleyes")"
ENV_PREFIX=${INSTALL_PREFIX}/env
# Check micromamba
if ! command -v micromamba &> /dev/null; then
    echo "Error: micromamba is not installed." >&2
    exit 1
fi

# Cleanup old installation
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

# Put app to /Applications folder
if [[ -d /Applications/FSLeyes.app || -L /Applications/FSLeyes.app ]]; then rm /Applications/FSLeyes.app; fi
ln -s ${ENV_PREFIX}/share/fsleyes/FSLeyes.app /Applications/FSLeyes.app

# Cleanup
micromamba clean -apyq

# Add following lines into .zshrc
echo "
Add following lines to .zshrc:

# FSLeyes
export FSLEYES_DIR=\"${SETUP_PREFIX}/fsleyes\"
export PATH=\"\${FSLEYES_DIR}/bin:\${PATH}\"
# Note: to use this version of fsleyes
# above lines should be put after FSL related lines
"
