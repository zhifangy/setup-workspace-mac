#!/bin/bash
set -e

# Setup
source $( dirname -- "$( readlink -f -- "$0"; )"; )/../envs
C3D_DIR=${SETUP_ROOT}/neurotools/convert3d
C3D_VERSION=${C3D_VERSION:-1.4.2}

# Cleanup old installation
if [ -d ${C3D_DIR} ]; then rm -rf ${C3D_DIR}; fi

# Install
echo "Installing Convert3D from SourceForge..."
mkdir -p ${C3D_DIR}
wget -q https://downloads.sourceforge.net/project/c3d/c3d/Experimental/c3d-${C3D_VERSION}-MacOS-arm64.dmg \
    -P ${C3D_DIR}
7zz x ${C3D_DIR}/c3d-${C3D_VERSION}-MacOS-arm64.dmg -o"${C3D_DIR}/" \
    c3d-${C3D_VERSION}-MacOS-arm64/Convert3DGUI.app > /dev/null
mv ${C3D_DIR}/c3d-${C3D_VERSION}-MacOS-arm64/Convert3DGUI.app ${C3D_DIR}/Convert3DGUI.app

# Cleanup
rm ${C3D_DIR}/c3d-${C3D_VERSION}-MacOS-arm64.dmg
rm -r ${C3D_DIR}/c3d-${C3D_VERSION}-MacOS-arm64

# Add following lines into .zshrc
echo "
Add following lines to .zshrc:

# Convert3D
export PATH=${C3D_DIR}/Convert3DGUI.app/Contents/bin:\${PATH}
"
