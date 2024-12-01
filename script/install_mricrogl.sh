#!/bin/bash
set -e

# Initialize environment
source "$(cd "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/utils.sh" && init_setup
# Set environment variables
INSTALL_PREFIX="$(eval "echo ${INSTALL_ROOT_PREFIX}/mricrogl")"
MRICROGL_VERSION=${MRICROGL_VERSION:-v1.2.20220720}

# Cleanup old installation
if [ -d ${INSTALL_PREFIX} ]; then rm -rf ${INSTALL_PREFIX}; fi

# Install
echo "Installing MRIcroGL from Github..."
mkdir -p ${INSTALL_PREFIX}


if [ "$OS_TYPE" == "macos" ]; then
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


elif [ "$OS_TYPE" == "rhel8" ]; then
wget -q https://github.com/rordenlab/MRIcroGL/releases/download/${MRICROGL_VERSION}/MRIcroGL_linux.zip \
    -P ${INSTALL_PREFIX}
unzip -q -o -d ${INSTALL_PREFIX}/tmp ${INSTALL_PREFIX}/MRIcroGL_linux.zip
mv ${INSTALL_PREFIX}/tmp/MRIcroGL/* ${INSTALL_PREFIX}

# Cleanup
rm ${INSTALL_PREFIX}/MRIcroGL_linux.zip
rm -r ${INSTALL_PREFIX}/tmp
fi

# Add following lines into .zshrc
echo "
Add following lines to .zshrc:

# MRIcroGL
export PATH=\"${INSTALL_ROOT_PREFIX}/mricrogl:\${PATH}\"
"
