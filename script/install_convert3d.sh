#!/bin/bash
set -e

# Get setup and script root directory
if [ -z "${SETUP_PREFIX}" ]; then
    echo "SETUP_PREFIX is not set or is empty. Defaulting to \${HOME}/Softwares."
    export SETUP_PREFIX='${HOME}/Softwares'
fi
# Set environment variables
C3D_DIR="$(eval "echo ${SETUP_PREFIX}/neurotools/convert3d")"
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
