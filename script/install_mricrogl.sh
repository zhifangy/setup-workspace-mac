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
wget -q https://github.com/rordenlab/MRIcroGL/releases/download/${MRICROGL_VERSION}/MRIcroMTLforMacOS_Sonoma.zip \
    -P ${INSTALL_PREFIX}
unzip -q -d ${INSTALL_PREFIX} ${INSTALL_PREFIX}/MRIcroMTLforMacOS_Sonoma.zip
7zz x ${INSTALL_PREFIX}/MRIcroMTL.dmg -o"${INSTALL_PREFIX}/" MRIcroMTL/MRIcroMTL.app > /dev/null
mv ${INSTALL_PREFIX}/MRIcroMTL/MRIcroMTL.app ${INSTALL_PREFIX}/MRIcroMTL.app

# Put app to /Applications folder
if [[ -d /Applications/MRIcroMTL.app || -L /Applications/MRIcroMTL.app ]]; then rm /Applications/MRIcroMTL.app; fi
ln -s ${INSTALL_PREFIX}/MRIcroMTL.app /Applications/MRIcroMTL.app

# Cleanup
rm ${INSTALL_PREFIX}/MRIcroMTLforMacOS_Sonoma.zip
rm ${INSTALL_PREFIX}/MRIcroMTL.dmg
rm -r ${INSTALL_PREFIX}/MRIcroMTL
if [ -d ${INSTALL_PREFIX}/__MACOSX ]; then rm -r ${INSTALL_PREFIX}/__MACOSX; fi

# Add following lines into .zshrc
echo "
Add following lines to .zshrc:

# MRIcroGL
export PATH=\"${SETUP_PREFIX}/mricrogl:\${PATH}\"
"
