#!/bin/bash
set -e

# Setup
source $( dirname -- "$( readlink -f -- "$0"; )"; )/../envs
QUARTO_DIR=${SETUP_ROOT}/quarto
QUARTO_VERSION=${QUARTO_VERSION:-1.4.533}

# Cleanup old installation
if [ -d ${QUARTO_DIR} ]; then rm -rf ${QUARTO_DIR}; fi

# Install
echo "Installing Quarto from Github..."
mkdir -p ${QUARTO_DIR}
wget -q https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-macos.tar.gz \
    -P ${QUARTO_DIR}
tar -xzf ${QUARTO_DIR}/quarto-${QUARTO_VERSION}-macos.tar.gz -C ${QUARTO_DIR} --strip-components 1
rm ${QUARTO_DIR}/quarto-${QUARTO_VERSION}-macos.tar.gz

# Add following lines into .zshrc
echo "
Add following lines to .zshrc:

# Quarto
export PATH=${QUARTO_DIR}/bin:\${PATH}
"
