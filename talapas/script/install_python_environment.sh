#!/bin/bash
set -e

# Get setup and script root directory
if [ -z "${SETUP_PREFIX}" ]; then
    echo "SETUP_PREFIX is not set or is empty. Defaulting to \${HOME}/Softwares."
    export SETUP_PREFIX='${HOME}/Softwares'
fi
SCRIPT_ROOT_DIR=$(dirname "$(dirname "$(realpath -- "$0")")")
# Set environment variables
export MAMBA_ROOT_PREFIX="$(eval "echo ${SETUP_PREFIX}/micromamba")"
eval "$(micromamba shell hook --shell bash --root-prefix ${MAMBA_ROOT_PREFIX})"
export \
    CONDA_ENVS_DIRS="${MAMBA_ROOT_PREFIX}/envs" \
    CONDA_PKGS_DIRS="${MAMBA_ROOT_PREFIX}/pkgs" \
    CONDA_CHANNELS="conda-forge,HCC"
export UV_ROOT_DIR="$(eval "echo ${SETUP_PREFIX}/uv")"
export \
    UV_BIN_DIR="${UV_ROOT_DIR}/bin" \
    UV_PYTHON_INSTALL_DIR="${UV_ROOT_DIR}/python" \
    UV_TOOL_DIR="${UV_ROOT_DIR}/tool" \
    UV_CACHE_DIR="${UV_ROOT_DIR}/cache"
export PY_LIBS="$(eval "echo ${SETUP_PREFIX}/pyenv")"
export PYTHON_VERSION="3.12"
export PATH="${UV_BIN_DIR}:${PATH}"

# Check if R is installed and in the PATH
if ( ! echo "$PATH" | tr ':' '\n' | grep -q "$(eval "echo ${SETUP_PREFIX}/r/bin")" ) || ( ! command -v R &> /dev/null ); then
    echo "ERROR: R is not installed or presents in the PATH (required by rpy2)."
    exit 1
fi

# Install UV
curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR="${UV_ROOT_DIR}/bin" INSTALLER_NO_MODIFY_PATH=1 sh

# Install uv-managed python
uv python install ${PYTHON_VERSION}

# Cleanup old python environment
if [ $(micromamba env list | grep -c ${PY_LIBS}) -ne 0 ]; then
    echo "Cleanup old environment ${PY_LIBS}..."
    micromamba env remove -p ${PY_LIBS} -yq
elif [ -d ${PY_LIBS} ]; then
    echo "Cleanup old environment ${PY_LIBS}..."
    rm -rf ${PY_LIBS}
fi

# Create python environment
micromamba create -yq -p ${PY_LIBS} && micromamba activate ${PY_LIBS}
# create venv (PEP 405 compliant) via UV in the environment directory
uv venv --allow-existing --seed --python ${PYTHON_VERSION} ${PY_LIBS}

# Install packages in venv via UV
uv pip install -r ${SCRIPT_ROOT_DIR}/misc/pyproject.toml --extra full
# special treatment for brainstat
uv pip install -r ${SCRIPT_ROOT_DIR}/misc/pyproject.toml --extra brainstat_deps
uv pip install -r ${SCRIPT_ROOT_DIR}/misc/pyproject.toml --extra brainstat_nodeps --no-deps

# Cleanup
uv cache clean

# Add following lines into .zshrc
echo "
Add following lines to .zshrc:

# UV
export UV_ROOT_DIR=\"${SETUP_PREFIX}/uv\"
export \\
    UV_BIN_DIR=\"\${UV_ROOT_DIR}/bin\" \\
    UV_PYTHON_INSTALL_DIR=\"\${UV_ROOT_DIR}/python\" \\
    UV_TOOL_DIR=\"\${UV_ROOT_DIR}/tool\" \\
    UV_CACHE_DIR=\"\${UV_ROOT_DIR}/cache\"
export PATH=\"\${UV_BIN_DIR}:\${PATH}\"

# Python environment
export PY_LIBS=\"${SETUP_PREFIX}/pyenv\"
micromamba activate \$PY_LIBS

Execute following lines:
source ~/.zshrc
"
