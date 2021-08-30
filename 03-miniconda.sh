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

# Poetry
export POETRY_HOME=${SETUP_ROOT}/poetry
curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/install-poetry.py | python -
unset POETRY_HOME

# Add following lines into .zshrc
echo "
Add following lines to .zshrc:
export PATH=${SETUP_ROOT}/poetry/bin:\${PATH}
export POETRY_CACHE_DIR=${SETUP_ROOT}/poetry
plugins(poetry)

Execute following lines:
source ~/.zshrc
mkdir -p \${ZSH_CUSTOM}/plugins/poetry
poetry completions zsh > \${ZSH_CUSTOM}/plugins/poetry/_poetry
"
