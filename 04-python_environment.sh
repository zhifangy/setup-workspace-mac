#!/bin/bash

if [ -z ${SETUP_ROOT} ]
then
    source envs
fi

# Create default conda enviornment on Mac
echo "Current conda: $(which conda)"

# Add channels
conda config --add channels conda-forge
conda config --set channel_priority flexible

# Environment name
ENV_PREFIX=${SETUP_ROOT}/pyenv
echo "Enviromenmet location: ${ENV_PREFIX}"

# Create environment
conda create -p ${ENV_PREFIX} -y python=3.8

# Activate environment
source $(conda info --base)/etc/profile.d/conda.sh
conda activate ${ENV_PREFIX}

# Install packages using poetry
POETRY_CACHE_DIR=${SETUP_ROOT}/poetry
cd "$(dirname "$0")"
poetry install -v
# Thingsvision
# Note:
# - Hard pin lots of packages
# - Manually install missing dependency
pip install -q --no-cache-dir --no-deps thingsvision

# Cleanup
conda clean -apy
jupyter lab clean

echo "Installation completed!"
