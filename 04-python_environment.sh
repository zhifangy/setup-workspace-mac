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
conda create -p ${ENV_PREFIX} -y python=3.9

# Activate environment
source $(conda info --base)/etc/profile.d/conda.sh
conda activate ${ENV_PREFIX}

# Install packages using conda
conda install -yq vtk=9.1.0

# Install packages using poetry
POETRY_CACHE_DIR=${SETUP_ROOT}/poetry
cd "$(dirname "$0")"
# remove old poetry.lock file
if [ -f poetry.lock ]; then
    rm poetry.lock
fi
# install
poetry install -v
# Thingsvision
# Note:
# - Hard pin lots of packages
# - Manually install missing dependency
pip install -q --no-cache-dir --no-deps thingsvision
# Pingouin
# Note:
# The package pinned scikit-learn<1.1.0 due to a bug in scikit-learn
# The bug has been fixed in scikit-learn v1.1.2
# Until pingouin releases a new version, installing it manually
pip install -q --no-cache-dir --no-deps pingouin
pip install -q --no-cache-dir outdated tabulate pandas_flavor

# Cleanup
conda clean -apy
jupyter lab clean

echo "Installation completed!"
