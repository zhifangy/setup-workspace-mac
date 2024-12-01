#!/bin/bash
set -e

# Initialize environment
source "$(cd "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/utils.sh" && init_setup
# Set environment variables
INSTALL_PREFIX="$(eval "echo ${INSTALL_ROOT_PREFIX}/surfice")"
SURFICE_VERSION=${SURFICE_VERSION:-v1.0.20211006}

# Cleanup old installation
if [ -d ${INSTALL_PREFIX} ]; then rm -rf ${INSTALL_PREFIX}; fi

# Install
echo "Installing Surfice from Github..."
mkdir -p ${INSTALL_PREFIX}


if [ "$OS_TYPE" == "macos" ]; then
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


elif [ "$OS_TYPE" == "rhel8" ]; then
wget -q https://github.com/neurolabusc/surf-ice/releases/download/${SURFICE_VERSION}/surfice_linux.zip \
    -P ${INSTALL_PREFIX}
unzip -q -o -d ${INSTALL_PREFIX}/tmp ${INSTALL_PREFIX}/surfice_linux.zip
mv ${INSTALL_PREFIX}/tmp/Surf_Ice/* ${INSTALL_PREFIX}

# Cleanup
rm ${INSTALL_PREFIX}/surfice_linux.zip
rm -r ${INSTALL_PREFIX}/tmp
fi

# Add following lines into .zshrc
echo "
Add following lines to .zshrc:

# Surfice
export PATH=\"${INSTALL_ROOT_PREFIX}/surfice:\${PATH}\"
"
