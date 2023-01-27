#!/bin/bash

if [ -z ${SETUP_ROOT} ]
then
    source envs
fi

# Setup
ANTS_DIR=${SETUP_ROOT}/ants
ANTS_VERSION=2.4.3

# Check and cleanup old installation
if [ -d ${ANTS_DIR} ]
then
    echo "Cleanup old ANTs installation ..."
    rm -rf ${ANTS_DIR}
fi

# ANTs
mkdir -p ${ANTS_DIR}
wget -O- https://github.com/ANTsX/ANTs/releases/download/v${ANTS_VERSION}/ants-${ANTS_VERSION}-macos-12-X64-clang.zip \
    | bsdtar -xf - -C ${ANTS_DIR} --strip-components 1
chmod +x ${ANTS_DIR}/bin/*

# Add following lines into .zshrc
echo "
Add following line to .zshrc
# ANTs
export ANTSPATH=${ANTS_DIR}/bin
export PATH=\${ANTSPATH}:\${PATH}
"
