#!/bin/bash
set -e

# Get setup and script root directory
if [ -z "${SETUP_PREFIX}" ]; then
    echo "SETUP_PREFIX is not set or is empty. Defaulting to \${HOME}/Softwares."
    export SETUP_PREFIX='${HOME}/Softwares'
fi
# Set environment variables
INSTALL_PREFIX="$(eval "echo ${SETUP_PREFIX}/surfice")"
SURFICE_VERSION=${SURFICE_VERSION:-v1.0.20211006}

# Cleanup old installation
if [ -d ${INSTALL_PREFIX} ]; then rm -rf ${INSTALL_PREFIX}; fi

# Install
echo "Installing Surfice from Github..."
mkdir -p ${INSTALL_PREFIX}
wget -q https://github.com/neurolabusc/surf-ice/releases/download/${SURFICE_VERSION}/surfice_linux.zip \
    -P ${INSTALL_PREFIX}
unzip -q -o -d ${INSTALL_PREFIX}/tmp ${INSTALL_PREFIX}/surfice_linux.zip
mv ${INSTALL_PREFIX}/tmp/Surf_Ice/* ${INSTALL_PREFIX}

# Cleanup
rm ${INSTALL_PREFIX}/surfice_linux.zip
rm -r ${INSTALL_PREFIX}/tmp

# Add following lines into .zshrc
echo "
Add following lines to .zshrc:

# Surfice
export PATH=\"${SETUP_PREFIX}/surfice:\${PATH}\"
"
