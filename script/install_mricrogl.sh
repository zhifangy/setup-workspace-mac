#!/bin/bash
set -e

# Setup
source $( dirname -- "$( readlink -f -- "$0"; )"; )/../envs
MRICROGL_DIR=${SETUP_ROOT}/neurotools/mricrogl
MRICROGL_VERSION=${MRICROGL_VERSION:-v1.2.20220720}

# Cleanup old installation
if [ -d ${MRICROGL_DIR} ]; then rm -rf ${MRICROGL_DIR}; fi

# Install
echo "Installing MRIcroGL from Github..."
mkdir -p ${MRICROGL_DIR}
wget -q https://github.com/rordenlab/MRIcroGL/releases/download/${MRICROGL_VERSION}/MRIcroGL_macOS.dmg \
    -P ${MRICROGL_DIR}
7zz x ${MRICROGL_DIR}/MRIcroGL_macOS.dmg -o"${MRICROGL_DIR}/" MRICroGL/MRICroGL.app > /dev/null
mv ${MRICROGL_DIR}/MRICroGL/MRICroGL.app ${MRICROGL_DIR}/MRICroGL.app

# Put app to /Applications folder
if [[ -d /Applications/MRICroGL.app || -L /Applications/MRICroGL.app ]]; then rm /Applications/MRICroGL.app; fi
ln -s ${MRICROGL_DIR}/MRICroGL.app /Applications/MRICroGL.app

# Cleanup
rm ${MRICROGL_DIR}/MRIcroGL_macOS.dmg
rm -r ${MRICROGL_DIR}/MRIcroGL

# Add following lines into .zshrc
echo "
Add following lines to .zshrc:

# MRIcroGL
export PATH=${MRICROGL_DIR}:\${PATH}
"
