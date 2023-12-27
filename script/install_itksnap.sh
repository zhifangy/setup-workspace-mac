#!/bin/bash
set -e

# Setup
source $( dirname -- "$( readlink -f -- "$0"; )"; )/../envs
ITKSNAP_DIR=${SETUP_ROOT}/neurotools/itksnap
ITKSNAP_VERSION=${ITKSNAP_VERSION:-4.0.2}
ITKSNAP_DATE=${ITKSNAP_DATE:-20230925}

# Cleanup old installation
if [ -d ${ITKSNAP_DIR} ]; then rm -rf ${ITKSNAP_DIR}; fi

# Install
echo "Installing ITK-SNAP from SourceForge..."
mkdir -p ${ITKSNAP_DIR}
wget -q https://sourceforge.net/projects/itk-snap/files/itk-snap/${ITKSNAP_VERSION}/itksnap-${ITKSNAP_VERSION}-Darwin-arm64.dmg \
    -P ${ITKSNAP_DIR}
7zz x ${ITKSNAP_DIR}/itksnap-${ITKSNAP_VERSION}-Darwin-arm64.dmg -o"${ITKSNAP_DIR}/" \
    itksnap-${ITKSNAP_VERSION}-${ITKSNAP_DATE}-Darwin-arm64/ITK-SNAP.app > /dev/null
mv ${ITKSNAP_DIR}/itksnap-${ITKSNAP_VERSION}-${ITKSNAP_DATE}-Darwin-arm64/ITK-SNAP.app ${ITKSNAP_DIR}/ITK-SNAP.app

# Put app to /Applications folder
if [[ -d /Applications/ITK-SNAP.app || -L /Applications/ITK-SNAP.app ]]; then rm /Applications/ITK-SNAP.app; fi
ln -s ${ITKSNAP_DIR}/ITK-SNAP.app /Applications/ITK-SNAP.app

# Cleanup
rm ${ITKSNAP_DIR}/itksnap-${ITKSNAP_VERSION}-Darwin-arm64.dmg
rm -r ${ITKSNAP_DIR}/itksnap-${ITKSNAP_VERSION}-${ITKSNAP_DATE}-Darwin-arm64

# Add following lines into .zshrc
echo "
Add following lines to .zshrc:

# ITKSNAP
export PATH=${ITKSNAP_DIR}:\${PATH}
"
