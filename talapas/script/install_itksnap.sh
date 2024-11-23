#!/bin/bash
set -e

# Get setup and script root directory
if [ -z "${SETUP_PREFIX}" ]; then
    echo "SETUP_PREFIX is not set or is empty. Defaulting to \${HOME}/Softwares."
    export SETUP_PREFIX='${HOME}/Softwares'
fi
# Set environment variables
INSTALL_PREFIX="$(eval "echo ${SETUP_PREFIX}/itksnap")"
ITKSNAP_VERSION=${ITKSNAP_VERSION:-4.2.0}
ITKSNAP_DATE=${ITKSNAP_DATE:-20240422}

# Cleanup old installation
if [ -d ${INSTALL_PREFIX} ]; then rm -rf ${INSTALL_PREFIX}; fi

# Install
echo "Installing ITK-SNAP from SourceForge..."
mkdir -p ${INSTALL_PREFIX}
wget -q https://downloads.sourceforge.net/project/itk-snap/itk-snap/${ITKSNAP_VERSION}/itksnap-${ITKSNAP_VERSION}-${ITKSNAP_DATE}-Linux-gcc64.tar.gz \
    -P ${INSTALL_PREFIX}
tar -xzf ${INSTALL_PREFIX}/itksnap-${ITKSNAP_VERSION}-${ITKSNAP_DATE}-Linux-gcc64.tar.gz -C ${INSTALL_PREFIX} --no-same-owner --no-same-permissions
mv ${INSTALL_PREFIX}/itksnap-${ITKSNAP_VERSION}-${ITKSNAP_DATE}-Linux-gcc64/* ${INSTALL_PREFIX}
# fix libQt*.so files
# see https://github.com/microsoft/WSL/issues/3023#issuecomment-372933586
find ${INSTALL_PREFIX} -name 'libQt*.so*' | xargs strip --remove-section=.note.ABI-tag

# Cleanup
rm ${INSTALL_PREFIX}/itksnap-4.2.0-20240422-Linux-gcc64.tar.gz
rm -r ${INSTALL_PREFIX}/itksnap-4.2.0-20240422-Linux-gcc64

# Add following lines into .zshrc
echo "
Add following lines to .zshrc:

# ITKSNAP
export PATH=\"${SETUP_PREFIX}/itksnap/bin:\${PATH}\"
"
