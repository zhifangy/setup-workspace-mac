#!/bin/bash
set -e

# Get setup and script root directory
if [ -z "${SETUP_PREFIX}" ]; then
    echo "SETUP_PREFIX is not set or is empty. Defaulting to \${HOME}/Softwares."
    export SETUP_PREFIX='${HOME}/Softwares'
fi
# Set environment variables
INSTALL_PREFIX="$(eval "echo ${SETUP_PREFIX}/convert3d")"
C3D_VERSION=${C3D_VERSION:-1.4.2}

# Cleanup old installation
if [ -d ${INSTALL_PREFIX} ]; then rm -rf ${INSTALL_PREFIX}; fi

# Install
echo "Installing Convert3D from SourceForge..."
mkdir -p ${INSTALL_PREFIX}
wget -q https://downloads.sourceforge.net/project/c3d/c3d/Experimental/c3d-${C3D_VERSION}-MacOS-arm64.dmg \
    -P ${INSTALL_PREFIX}
7zz x ${INSTALL_PREFIX}/c3d-${C3D_VERSION}-MacOS-arm64.dmg -o"${INSTALL_PREFIX}/" \
    c3d-${C3D_VERSION}-MacOS-arm64/Convert3DGUI.app > /dev/null
mv ${INSTALL_PREFIX}/c3d-${C3D_VERSION}-MacOS-arm64/Convert3DGUI.app ${INSTALL_PREFIX}/Convert3DGUI.app

# Cleanup
rm ${INSTALL_PREFIX}/c3d-${C3D_VERSION}-MacOS-arm64.dmg
rm -r ${INSTALL_PREFIX}/c3d-${C3D_VERSION}-MacOS-arm64

# Add following lines into .zshrc
echo "
Add following lines to .zshrc:

# Convert3D
export PATH=\"${SETUP_PREFIX}/convert3d/Convert3DGUI.app/Contents/bin:\${PATH}\"
"
