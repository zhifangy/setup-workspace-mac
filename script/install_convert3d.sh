#!/bin/bash
set -e

if [ -z ${SETUP_ROOT} ]; then source $( dirname -- "$( readlink -f -- "$0"; )"; )/../envs; fi
# Setup
BASE_DIR=${SETUP_ROOT}/neurotools
C3D_VERSION=${C3D_VERSION:-1.4.0}
C3D_DIR=${BASE_DIR}/convert3d

# Cleanup old installation
if [ -d ${C3D_DIR} ]; then rm -rf ${C3D_DIR}; fi

# Install
echo "Installing Convert3D from SourceForge..."
mkdir -p ${C3D_DIR}
wget -q https://downloads.sourceforge.net/project/c3d/c3d/Experimental/c3d-${C3D_VERSION}-MacOS-x86_64.dmg \
    -P ${C3D_DIR}
7zz x ${C3D_DIR}/c3d-${C3D_VERSION}-MacOS-x86_64.dmg -o"${C3D_DIR}/" \
    c3d-${C3D_VERSION}-MacOS-x86_64/Convert3DGUI.app > /dev/null
mv ${C3D_DIR}/c3d-${C3D_VERSION}-MacOS-x86_64/Convert3DGUI.app ${C3D_DIR}/Convert3DGUI.app

# Cleanup
rm ${C3D_DIR}/c3d-${C3D_VERSION}-MacOS-x86_64.dmg
rm -r ${C3D_DIR}/c3d-${C3D_VERSION}-MacOS-x86_64

# Add following lines into .zshrcx
echo "
Add following lines to .zshrc:

# Convert3D
export PATH=${C3D_DIR}/Convert3DGUI.app/Contents/bin:\${PATH}
"
