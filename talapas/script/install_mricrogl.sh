#!/bin/bash
set -e

# Get setup and script root directory
if [ -z "${SETUP_PREFIX}" ]; then
    echo "SETUP_PREFIX is not set or is empty. Defaulting to \${HOME}/Softwares."
    export SETUP_PREFIX='${HOME}/Softwares'
fi
# Set environment variables
INSTALL_PREFIX="$(eval "echo ${SETUP_PREFIX}/mricrogl")"
MRICROGL_VERSION=${MRICROGL_VERSION:-v1.2.20220720}

# Cleanup old installation
if [ -d ${INSTALL_PREFIX} ]; then rm -rf ${INSTALL_PREFIX}; fi

# Install
echo "Installing MRIcroGL from Github..."
mkdir -p ${INSTALL_PREFIX}
wget -q https://github.com/rordenlab/MRIcroGL/releases/download/${MRICROGL_VERSION}/MRIcroGL_linux.zip \
    -P ${INSTALL_PREFIX}
unzip -q -o -d ${INSTALL_PREFIX}/tmp ${INSTALL_PREFIX}/MRIcroGL_linux.zip
mv ${INSTALL_PREFIX}/tmp/MRIcroGL/* ${INSTALL_PREFIX}

# Cleanup
rm ${INSTALL_PREFIX}/MRIcroGL_linux.zip
rm -r ${INSTALL_PREFIX}/tmp

# Add following lines into .zshrc
echo "
Add following lines to .zshrc:

# MRIcroGL
export PATH=\"${SETUP_PREFIX}/mricrogl:\${PATH}\"
"
