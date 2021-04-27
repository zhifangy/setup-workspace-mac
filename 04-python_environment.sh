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

conda install -yq \
    "python>=3.8" \
    numpy \
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
    plotly-orca \
    bokeh \
    graphviz \
    vtk \
    mayavi \
    ffmpeg \
    ipywidgets \
    nodejs \
    spyder \
    mpi4py \
    h5py \
    feather-format \
    cython \
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
    mne \
    nitime \
    pydicom \
    dcmstack \
    heudiconv \
    umap-learn \
    gensim \
    pyrsistent \
    pint \
    py4j \
    s3fs \
    ipyvolume \
    datalad

# Install packages using pip
pip install -q --no-cache-dir \
    lets-plot \
    rpy2 \
    radian \
    pymer4 \
    sklearn-lmer \
    bigmpi4py \
    pymanopt \
    pybids \
    bidscoin \
    antspyx \
    brainiak \
    hypertools \
    neuropythy \
    pymvpa2 \
    visualqc

# Install jupyterlab extensions
jupyter labextension install jupyterlab-plotly
jupyter labextension install plotlywidget
jupyter labextension install ipyvolume
jupyter labextension install jupyter-threejs

# Cleanup
conda clean -apy
jupyter lab clean

echo "Installation completed!"