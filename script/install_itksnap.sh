#!/bin/bash
set -e

if [ -z ${SETUP_ROOT} ]; then source $( dirname -- "$( readlink -f -- "$0"; )"; )/../envs; fi
# Setup
BASE_DIR=${SETUP_ROOT}/neurotools
ITKSNAP_VERSION=${ITKSNAP_VERSION:-4.0.1}
ITKSNAP_DATE=${ITKSNAP_DATE:-20230320}
ITKSNAP_DIR=${BASE_DIR}/itksnap

# Cleanup old installation
if [ -d ${ITKSNAP_DIR} ]; then rm -rf ${ITKSNAP_DIR}; fi

# Install
echo "Installing ITK-SNAP from SourceForge..."
mkdir -p ${ITKSNAP_DIR}
wget -q https://downloads.sourceforge.net/project/itk-snap/itk-snap/${ITKSNAP_VERSION}/itksnap-${ITKSNAP_VERSION}-${ITKSNAP_DATE}-Darwin-x86_64.dmg \
    -P ${ITKSNAP_DIR}
7zz x ${ITKSNAP_DIR}/itksnap-${ITKSNAP_VERSION}-${ITKSNAP_DATE}-Darwin-x86_64.dmg -o"${ITKSNAP_DIR}/" \
    itksnap-${ITKSNAP_VERSION}-${ITKSNAP_DATE}-Darwin-x86_64/ITK-SNAP.app > /dev/null
mv ${ITKSNAP_DIR}/itksnap-${ITKSNAP_VERSION}-${ITKSNAP_DATE}-Darwin-x86_64/ITK-SNAP.app ${ITKSNAP_DIR}/ITK-SNAP.app

# Put app to /Applications folder
if [[ -d /Applications/ITK-SNAP.app || -L /Applications/ITK-SNAP.app ]]; then rm /Applications/ITK-SNAP.app; fi
ln -s ${ITKSNAP_DIR}/ITK-SNAP.app /Applications/ITK-SNAP.app

# Cleanup
rm ${ITKSNAP_DIR}/itksnap-${ITKSNAP_VERSION}-${ITKSNAP_DATE}-Darwin-x86_64.dmg
rm -r ${ITKSNAP_DIR}/itksnap-${ITKSNAP_VERSION}-${ITKSNAP_DATE}-Darwin-x86_64

# Add following lines into .zshrcx
echo "
Add following lines to .zshrc:

# ITKSNAP
export PATH=${ITKSNAP_DIR}:\${PATH}
"
