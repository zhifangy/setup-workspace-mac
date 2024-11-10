#!/bin/bash
set -e

# Get setup and script root directory
if [ -z "${SETUP_PREFIX}" ]; then
    echo "SETUP_PREFIX is not set or is empty. Defaulting to \${HOME}/Softwares."
    export SETUP_PREFIX='${HOME}/Softwares'
fi
# Set environment variables
BASE_DIR="$(eval "echo ${SETUP_PREFIX}/neurotools")"
WORKBENCH_DIR="$(eval "echo ${SETUP_PREFIX}/neurotools/workbench")"
WORKBENCH_VERSION=${WORKBENCH_VERSION:-v2.0.1}

# Cleanup old installation
if [ -d ${WORKBENCH_DIR} ]; then rm -rf ${WORKBENCH_DIR}; fi

# Install
echo "Installing Workbench from humanconnectome.org..."
wget -q https://www.humanconnectome.org/storage/app/media/workbench/workbench-macub-${WORKBENCH_VERSION}.zip \
    -P ${BASE_DIR}
unzip -q -d ${BASE_DIR} ${BASE_DIR}/workbench-macub-${WORKBENCH_VERSION}.zip

# Put app to /Applications folder
if [[ -d /Applications/Workbench.app || -L /Applications/Workbench.app ]]; then rm /Applications/Workbench.app; fi
ln -s ${WORKBENCH_DIR}/macosxub_apps/wb_view.app /Applications/Workbench.app

# Cleanup
rm ${BASE_DIR}/workbench-macub-${WORKBENCH_VERSION}.zip

# Add following lines into .zshrc
echo "
Add following lines to .zshrc:

# HCP Workbench
export PATH=${WORKBENCH_DIR}/bin_macosxub:\${PATH}
"
