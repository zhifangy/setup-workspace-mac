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
wget -q https://github.com/neurolabusc/surf-ice/releases/download/${SURFICE_VERSION}/Surfice_macOS.dmg \
    -P ${INSTALL_PREFIX}
7zz x ${INSTALL_PREFIX}/Surfice_macOS.dmg -o"${INSTALL_PREFIX}/" -xr"!*:com.*" -xr"!.DS_Store" \
    Surfice/Surfice > /dev/null
mv ${INSTALL_PREFIX}/Surfice/Surfice/* ${INSTALL_PREFIX}

# Put app to /Applications folder
if [[ -d /Applications/Surfice.app || -L /Applications/Surfice.app ]]; then rm /Applications/Surfice.app; fi
ln -s ${INSTALL_PREFIX}/surfice.app /Applications/Surfice.app

# Cleanup
rm ${INSTALL_PREFIX}/Surfice_macOS.dmg
rm -r ${INSTALL_PREFIX}/Surfice

# Add following lines into .zshrc
echo "
Add following lines to .zshrc:

# Surfice
export PATH=\"${SETUP_PREFIX}/surfice:\${PATH}\"
"
