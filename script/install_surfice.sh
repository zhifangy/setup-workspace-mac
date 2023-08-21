#!/bin/bash
set -e

if [ -z ${SETUP_ROOT} ]; then source $( dirname -- "$( readlink -f -- "$0"; )"; )/../envs; fi
# Setup
BASE_DIR=${SETUP_ROOT}/neurotools
SURFICE_VERSION=${SURFICE_VERSION:-v1.0.20211006}
SURFICE_DIR=${BASE_DIR}/surfice

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

# Add following lines into .zshrcx
echo "
Add following lines to .zshrc:

# Surfice
export PATH=${SURFICE_DIR}:\${PATH}
"
