#!/bin/bash

if [ -z ${SETUP_ROOT} ]
then
    source envs
fi

# Setup
ANTS_DIR=${SETUP_ROOT}/ants
BUILD_DIR=${SETUP_ROOT}/ANTs_build
if [ -z ${N_CPUS} ]; then N_CPUS=4; fi

# ANTs
mkdir -p ${BUILD_DIR}/build
wget -O- https://github.com/ANTsX/ANTs/archive/v2.3.4.tar.gz \
    | tar -xzC ${BUILD_DIR} --strip-components 1
cd ${BUILD_DIR}/build
cmake -DCMAKE_INSTALL_PREFIX=${ANTS_DIR} ${BUILD_DIR}
make -j ${N_CPUS}
cd ANTs-build
make install

# Cleanups
cd ${SETUP_DIR}
rm -rf ${BUILD_DIR}

# Add following lines into .zshrc
echo "
Add following line to .zshrc
# ANTs
export ANTSPATH=${ANTS_DIR}/bin
export PATH=\${ANTSPATH}:\${PATH}
"
