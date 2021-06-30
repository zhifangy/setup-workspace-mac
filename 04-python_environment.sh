#!/bin/bash

if [ -z ${SETUP_ROOT} ]
then
    source envs
fi

# Create default conda enviornment on Mac
echo "Current conda: $(which conda)"

# Add channels
conda config --add channels conda-forge
conda config --add channels pytorch
conda config --set channel_priority flexible

# Environment name
ENV_PREFIX=${SETUP_ROOT}/pyenv
echo "Enviromenmet location: ${ENV_PREFIX}"

# Create environment
conda create -p ${ENV_PREFIX} -y python=3.8

# Activate environment
source $(conda info --base)/etc/profile.d/conda.sh
conda activate ${ENV_PREFIX}

# Install packages using conda
# Note:
# - Pin numpy=1.19, since several packages are incompatible with numpy 1.20.
# - Checklist: tensorflow, brainiak, yellowbrick
conda install -yq \
    "numpy=1.19" \
    pandas \
    scipy \
    statsmodels \
    scikit-learn \
    scikit-image \
    xgboost \
    ipython \
    jupyterlab \
    jupyterlab-lsp \
    jupyter-lsp-python \
    xeus-python \
    jupyterlab_code_formatter \
    matplotlib \
    seaborn \
    plotly \
    python-kaleido \
    bokeh \
    ipywidgets \
    mpi4py \
    h5py \
    pybind11 \
    flake8 \
    autopep8 \
    black \
    yapf \
    pytest \
    jupytext \
    nbdime \
    pyjanitor \
    python-dotenv \
    pyprojroot \
    memory_profiler \
    threadpoolctl \
    cookiecutter \
    pytorch \
    torchvision \
    cudatoolkit \
    nilearn \
    nipype \
    nitime \
    pydicom \
    dcmstack \
    heudiconv \
    umap-learn \
    gensim \
    numexpr \
    pyrsistent \
    pint \
    py4j \
    s3fs \
    ipyvolume \
    datalad

# Install packages using pip
# Note:
pip install -q --no-cache-dir \
    lets-plot \
    timm \
    yellowbrick \
    rpy2 \
    radian \
    bigmpi4py \
    pymanopt \
    pybids \
    bidscoin \
    antspyx \
    brainiak \
    brainspace \
    neuropythy \
    pymvpa2 \
    visualqc
# Install vtk, mayavi
# Note:
# - conda-forge version conflicts with lots of packages
pip install -q --no-cache-dir vtk
pip install -q --no-cache-dir mayavi
# Install mne
# conda-forge version requests mayavi
pip install -q --no-cache-dir -r \
    <(curl -s https://raw.githubusercontent.com/mne-tools/mne-python/main/requirements.txt)
pip install -q --no-cache-dir mne
# Install hypertools
# version 0.7.0 requires scikit-learn<0.24
pip install -q --no-cache-dir ppca
pip install -q --no-cache-dir --no-deps hypertools
# pymer4
# Note:
# - Require old version of pandas due to deepdish
# - Manually install missing dependency
pip install -q --no-cache-dir deepdish
pip install -q --no-cache-dir --no-deps pymer4
# Thingsvision
# Note:
# - Hard pin lots of packages
# - Manually install missing dependency
pip install -q --no-cache-dir ftfy
pip install -q --no-cache-dir --no-deps thingsvision

# Cleanup
conda clean -apy
jupyter lab clean

echo "Installation completed!"
echo "Add 'numpy<1.20' into pyenv/conda-meta/pinned file."
