#!/bin/bash
set -e

if [ -z ${SETUP_ROOT} ]; then source $( dirname -- "$( readlink -f -- "$0"; )"; )/../envs; fi
# Setup
BASE_DIR=${SETUP_ROOT}/neurotools
WORKBENCH_VERSION=${WORKBENCH_VERSION:-v1.5.0}
WORKBENCH_DIR=${BASE_DIR}/workbench

# Cleanup old installation
if [ -d ${WORKBENCH_DIR} ]; then rm -rf ${WORKBENCH_DIR}; fi

# Install
echo "Installing Workbench from humanconnectome.org..."
wget -q https://www.humanconnectome.org/storage/app/media/workbench/workbench-mac64-${WORKBENCH_VERSION}.zip \
    -P ${BASE_DIR}
unzip -q -d ${BASE_DIR} ${BASE_DIR}/workbench-mac64-${WORKBENCH_VERSION}.zip
# fix permission
chmod 755 ${WORKBENCH_DIR}/bin_macosx64 ${WORKBENCH_DIR}/macosx64_apps
chmod 755 ${WORKBENCH_DIR}/bin_macosx64/* ${WORKBENCH_DIR}/macosx64_apps/*
chmod 644 ${WORKBENCH_DIR}/README.txt

# Put app to /Applications folder
if [ -d /Applications/Workbench.app ]; then rm /Applications/Workbench.app; fi
ln -s ${WORKBENCH_DIR}/macosx64_apps/wb_view.app /Applications/Workbench.app

# Cleanup
rm ${BASE_DIR}/workbench-mac64-${WORKBENCH_VERSION}.zip

# Add following lines into .zshrcx
echo "
Add following lines to .zshrc:

# HCP Workbench
export PATH=${WORKBENCH_DIR}/bin_macosx64:\${PATH}
"
