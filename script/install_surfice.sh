#!/bin/bash
set -e

# Get setup and script root directory
if [ -z "${SETUP_PREFIX}" ]; then
    echo "SETUP_PREFIX is not set or is empty. Defaulting to \${HOME}/Softwares."
    export SETUP_PREFIX='${HOME}/Softwares'
fi
# Set environment variables
SURFICE_DIR="$(eval "echo ${SETUP_PREFIX}/neurotools/surfice")"
SURFICE_VERSION=${SURFICE_VERSION:-v1.0.20211006}

# Cleanup old installation
if [ -d ${SURFICE_DIR} ]; then rm -rf ${SURFICE_DIR}; fi

# Install
echo "Installing Surfice from Github..."
mkdir -p ${SURFICE_DIR}
wget -q https://github.com/neurolabusc/surf-ice/releases/download/${SURFICE_VERSION}/Surfice_macOS.dmg \
    -P ${SURFICE_DIR}
7zz x ${SURFICE_DIR}/Surfice_macOS.dmg -o"${SURFICE_DIR}/" -xr"!*:com.*" -xr"!.DS_Store" \
    Surfice/Surfice > /dev/null
mv ${SURFICE_DIR}/Surfice/Surfice/* ${SURFICE_DIR}

# Put app to /Applications folder
if [[ -d /Applications/Surfice.app || -L /Applications/Surfice.app ]]; then rm /Applications/Surfice.app; fi
ln -s ${SURFICE_DIR}/surfice.app /Applications/Surfice.app

# Cleanup
rm ${SURFICE_DIR}/Surfice_macOS.dmg
rm -r ${SURFICE_DIR}/Surfice

# Add following lines into .zshrc
echo "
Add following lines to .zshrc:

# Surfice
export PATH=${SURFICE_DIR}:\${PATH}
"
