#!/bin/bash
set -e

# Get setup and script root directory
if [ -z "${SETUP_PREFIX}" ]; then
    echo "SETUP_PREFIX is not set or is empty. Defaulting to \${HOME}/Softwares."
    export SETUP_PREFIX='${HOME}/Softwares'
fi
# Set environment variables
INSTALL_PREFIX="$(eval "echo ${SETUP_PREFIX}/workbench")"
WORKBENCH_VERSION=${WORKBENCH_VERSION:-v2.0.1}

# Cleanup old installation
if [ -d ${INSTALL_PREFIX} ]; then rm -rf ${INSTALL_PREFIX}; fi

# Install
echo "Installing Workbench from humanconnectome.org..."
mkdir -p ${INSTALL_PREFIX}
wget -q https://www.humanconnectome.org/storage/app/media/workbench/workbench-rh_linux64-${WORKBENCH_VERSION}.zip \
    -P ${INSTALL_PREFIX}
unzip -q -o -d ${INSTALL_PREFIX}/tmp ${INSTALL_PREFIX}/workbench-rh_linux64-${WORKBENCH_VERSION}.zip
mv ${INSTALL_PREFIX}/tmp/workbench/* ${INSTALL_PREFIX}

# Cleanup
rm ${INSTALL_PREFIX}/workbench-rh_linux64-v2.0.1.zip
rm -r ${INSTALL_PREFIX}/tmp

# Add following lines into .zshrc
echo "
Add following lines to .zshrc:

# HCP Workbench
export PATH=\"${SETUP_PREFIX}/workbench/bin_rh_linux64:\${PATH}\"
"
