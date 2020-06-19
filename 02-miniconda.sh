#!/bin/bash

if [ -z ${SETUP_ROOT} ]
then
    source envs
fi

# Setup
CONDA_DIR=${SETUP_ROOT}/miniconda
PATH=${CONDA_DIR}/bin:${PATH}

# Miniconda
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh
bash Miniconda3-latest-MacOSX-x86_64.sh -b -p ${CONDA_DIR}
rm -f Miniconda3-latest-MacOSX-x86_64.sh
conda config --prepend channels conda-forge
conda update -yq conda
conda update -yq --all
