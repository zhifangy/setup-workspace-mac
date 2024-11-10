#!/bin/bash
set -e

# Get setup and script root directory
if [ -z "${SETUP_PREFIX}" ]; then
    echo "SETUP_PREFIX is not set or is empty. Defaulting to \${HOME}/Softwares."
    export SETUP_PREFIX='${HOME}/Softwares'
fi
# Set environment variables
MRICROGL_DIR="$(eval "echo ${SETUP_PREFIX}/neurotools/mricrogl")"
MRICROGL_VERSION=${MRICROGL_VERSION:-v1.2.20220720}

# Cleanup old installation
if [ -d ${MRICROGL_DIR} ]; then rm -rf ${MRICROGL_DIR}; fi

# Install
echo "Installing MRIcroGL from Github..."
mkdir -p ${MRICROGL_DIR}
wget -q https://github.com/rordenlab/MRIcroGL/releases/download/${MRICROGL_VERSION}/MRIcroMTLforMacOS_Sonoma.zip \
    -P ${MRICROGL_DIR}
unzip -q -d ${MRICROGL_DIR} ${MRICROGL_DIR}/MRIcroMTLforMacOS_Sonoma.zip
7zz x ${MRICROGL_DIR}/MRIcroMTL.dmg -o"${MRICROGL_DIR}/" MRIcroMTL/MRIcroMTL.app > /dev/null
mv ${MRICROGL_DIR}/MRIcroMTL/MRIcroMTL.app ${MRICROGL_DIR}/MRIcroMTL.app

# Put app to /Applications folder
if [[ -d /Applications/MRIcroMTL.app || -L /Applications/MRIcroMTL.app ]]; then rm /Applications/MRIcroMTL.app; fi
ln -s ${MRICROGL_DIR}/MRIcroMTL.app /Applications/MRIcroMTL.app

# Cleanup
rm ${MRICROGL_DIR}/MRIcroMTLforMacOS_Sonoma.zip
rm ${MRICROGL_DIR}/MRIcroMTL.dmg
rm -r ${MRICROGL_DIR}/MRIcroMTL
if [ -d ${MRICROGL_DIR}/__MACOSX ]; then rm -r ${MRICROGL_DIR}/__MACOSX; fi

# Add following lines into .zshrc
echo "
Add following lines to .zshrc:

# MRIcroGL
export PATH=${MRICROGL_DIR}:\${PATH}
"
